from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import Optional
import sqlite3
import os

app = FastAPI(title="Digital Society API", version="2.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

DB_PATH = os.path.join(os.path.dirname(__file__), "society.db")


def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn


def init_db():
    conn = get_db()
    conn.executescript("""
        CREATE TABLE IF NOT EXISTS members (
            houseno   TEXT PRIMARY KEY,
            familyname TEXT NOT NULL,
            totalmembers INTEGER DEFAULT 0,
            password  TEXT NOT NULL,
            role      TEXT DEFAULT 'member'
        );

        CREATE TABLE IF NOT EXISTS family_details (
            id        INTEGER PRIMARY KEY AUTOINCREMENT,
            houseno   TEXT NOT NULL,
            name      TEXT NOT NULL,
            contactno TEXT,
            age       TEXT,
            gender    TEXT,
            FOREIGN KEY (houseno) REFERENCES members(houseno)
        );

        CREATE TABLE IF NOT EXISTS complaints (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            houseno     TEXT NOT NULL,
            title       TEXT NOT NULL,
            description TEXT,
            date        TEXT NOT NULL,
            status      TEXT DEFAULT 'Pending',
            finish_date TEXT,
            action      TEXT,
            feedback    TEXT,
            FOREIGN KEY (houseno) REFERENCES members(houseno)
        );

        CREATE TABLE IF NOT EXISTS notices (
            id       INTEGER PRIMARY KEY AUTOINCREMENT,
            head     TEXT NOT NULL,
            content  TEXT NOT NULL,
            date     TEXT NOT NULL,
            issue_by TEXT NOT NULL
        );

        CREATE TABLE IF NOT EXISTS maintenance (
            id             INTEGER PRIMARY KEY AUTOINCREMENT,
            houseno        TEXT NOT NULL,
            month          TEXT NOT NULL,
            year           TEXT NOT NULL,
            amount         REAL DEFAULT 0,
            status         TEXT DEFAULT 'Pending',
            paid_date      TEXT,
            transaction_id TEXT,
            FOREIGN KEY (houseno) REFERENCES members(houseno)
        );
    """)

    # Seed default committee accounts
    conn.execute("""
        INSERT OR IGNORE INTO members (houseno, familyname, totalmembers, password, role)
        VALUES ('C001', 'Chairman', 1, 'chairman123', 'chairman')
    """)
    conn.execute("""
        INSERT OR IGNORE INTO members (houseno, familyname, totalmembers, password, role)
        VALUES ('S001', 'Secretary', 1, 'secretary123', 'secretary')
    """)
    conn.execute("""
        INSERT OR IGNORE INTO members (houseno, familyname, totalmembers, password, role)
        VALUES ('T001', 'Treasurer', 1, 'treasurer123', 'treasurer')
    """)
    conn.commit()
    conn.close()


init_db()


# ── Pydantic models ────────────────────────────────────────────────────────────

class MemberCreate(BaseModel):
    houseno: str
    familyname: str
    totalmembers: int
    password: str


class FamilyMemberCreate(BaseModel):
    houseno: str
    name: str
    contactno: str
    age: str
    gender: str


class ComplaintCreate(BaseModel):
    houseno: str
    title: str
    description: str
    date: str
    status: str = "Pending"


class ComplaintUpdate(BaseModel):
    status: Optional[str] = None
    action: Optional[str] = None
    feedback: Optional[str] = None
    finish_date: Optional[str] = None


class NoticeCreate(BaseModel):
    head: str
    content: str
    date: str
    issue_by: str


class MaintenanceCreate(BaseModel):
    houseno: str
    month: str
    year: str
    amount: float


class MaintenanceUpdate(BaseModel):
    status: str
    paid_date: Optional[str] = None
    transaction_id: Optional[str] = None


# ── Routes ─────────────────────────────────────────────────────────────────────

@app.get("/")
def root():
    return {"message": "Digital Society API v2.0 is running"}


# Members
@app.get("/members")
def get_members():
    conn = get_db()
    rows = conn.execute(
        "SELECT houseno, familyname, password, role FROM members"
    ).fetchall()
    conn.close()
    return [dict(r) for r in rows]


@app.post("/members")
def add_member(m: MemberCreate):
    conn = get_db()
    try:
        conn.execute(
            "INSERT INTO members (houseno, familyname, totalmembers, password) VALUES (?,?,?,?)",
            (m.houseno, m.familyname, m.totalmembers, m.password),
        )
        conn.commit()
        conn.close()
        return {"response": "successfully added"}
    except sqlite3.IntegrityError:
        conn.close()
        raise HTTPException(status_code=400, detail="House number already exists")


@app.get("/all_details")
def get_all_details():
    conn = get_db()
    rows = conn.execute("""
        SELECT m.houseno, m.familyname,
               f.name, f.contactno, f.age, f.gender
        FROM members m
        LEFT JOIN family_details f ON m.houseno = f.houseno
        WHERE m.role = 'member'
        ORDER BY m.houseno
    """).fetchall()
    conn.close()

    result: dict = {}
    for r in rows:
        r = dict(r)
        hn = r["houseno"]
        if hn not in result:
            result[hn] = {"houseno": hn, "familyname": r["familyname"], "family": []}
        if r["name"]:
            result[hn]["family"].append({
                "name": r["name"],
                "contactno": r["contactno"],
                "age": r["age"],
                "gender": r["gender"],
            })
    return list(result.values())


# Family members
@app.post("/family_members")
def add_family_member(f: FamilyMemberCreate):
    conn = get_db()
    conn.execute(
        "INSERT INTO family_details (houseno, name, contactno, age, gender) VALUES (?,?,?,?,?)",
        (f.houseno, f.name, f.contactno, f.age, f.gender),
    )
    conn.commit()
    conn.close()
    return {"response": "successfully added"}


# Notices
@app.get("/notices")
def get_notices():
    conn = get_db()
    rows = conn.execute("SELECT * FROM notices ORDER BY date DESC, id DESC").fetchall()
    conn.close()
    return [dict(r) for r in rows]


@app.post("/notices")
def add_notice(n: NoticeCreate):
    conn = get_db()
    conn.execute(
        "INSERT INTO notices (head, content, date, issue_by) VALUES (?,?,?,?)",
        (n.head, n.content, n.date, n.issue_by),
    )
    conn.commit()
    conn.close()
    return {"response": "successfully added"}


@app.delete("/notices/{notice_id}")
def delete_notice(notice_id: int):
    conn = get_db()
    conn.execute("DELETE FROM notices WHERE id = ?", (notice_id,))
    conn.commit()
    conn.close()
    return {"response": "deleted"}


# Complaints
@app.get("/complaints")
def get_complaints():
    conn = get_db()
    rows = conn.execute("SELECT * FROM complaints ORDER BY date DESC, id DESC").fetchall()
    conn.close()
    return [dict(r) for r in rows]


@app.get("/complaints/{houseno}")
def get_member_complaints(houseno: str):
    conn = get_db()
    rows = conn.execute(
        "SELECT * FROM complaints WHERE houseno = ? ORDER BY date DESC, id DESC",
        (houseno,),
    ).fetchall()
    conn.close()
    return [dict(r) for r in rows]


@app.post("/complaints")
def add_complaint(c: ComplaintCreate):
    conn = get_db()
    conn.execute(
        "INSERT INTO complaints (houseno, title, description, date, status) VALUES (?,?,?,?,?)",
        (c.houseno, c.title, c.description, c.date, c.status),
    )
    conn.commit()
    conn.close()
    return {"response": "successfully added"}


@app.put("/complaints/{complaint_id}")
def update_complaint(complaint_id: int, u: ComplaintUpdate):
    conn = get_db()
    conn.execute("""
        UPDATE complaints
        SET status      = COALESCE(?, status),
            action      = COALESCE(?, action),
            feedback    = COALESCE(?, feedback),
            finish_date = COALESCE(?, finish_date)
        WHERE id = ?
    """, (u.status, u.action, u.feedback, u.finish_date, complaint_id))
    conn.commit()
    conn.close()
    return {"response": "updated"}


# Maintenance
@app.get("/maintenance")
def get_maintenance():
    conn = get_db()
    rows = conn.execute("""
        SELECT ma.*, m.familyname
        FROM maintenance ma
        JOIN members m ON ma.houseno = m.houseno
        ORDER BY ma.year DESC, ma.month DESC
    """).fetchall()
    conn.close()
    return [dict(r) for r in rows]


@app.get("/maintenance/{houseno}")
def get_member_maintenance(houseno: str):
    conn = get_db()
    rows = conn.execute(
        "SELECT * FROM maintenance WHERE houseno = ? ORDER BY year DESC, month DESC",
        (houseno,),
    ).fetchall()
    conn.close()
    return [dict(r) for r in rows]


@app.post("/maintenance")
def add_maintenance(m: MaintenanceCreate):
    conn = get_db()
    try:
        conn.execute(
            "INSERT INTO maintenance (houseno, month, year, amount) VALUES (?,?,?,?)",
            (m.houseno, m.month, m.year, m.amount),
        )
        conn.commit()
        conn.close()
        return {"response": "successfully added"}
    except Exception as e:
        conn.close()
        raise HTTPException(status_code=400, detail=str(e))


@app.put("/maintenance/{maintenance_id}")
def update_maintenance(maintenance_id: int, u: MaintenanceUpdate):
    conn = get_db()
    conn.execute(
        "UPDATE maintenance SET status=?, paid_date=?, transaction_id=? WHERE id=?",
        (u.status, u.paid_date, u.transaction_id, maintenance_id),
    )
    conn.commit()
    conn.close()
    return {"response": "updated"}


# Stats (for committee dashboard)
@app.get("/stats")
def get_stats():
    conn = get_db()
    total_members = conn.execute(
        "SELECT COUNT(*) FROM members WHERE role = 'member'"
    ).fetchone()[0]
    pending_complaints = conn.execute(
        "SELECT COUNT(*) FROM complaints WHERE status = 'Pending'"
    ).fetchone()[0]
    total_complaints = conn.execute("SELECT COUNT(*) FROM complaints").fetchone()[0]
    total_notices = conn.execute("SELECT COUNT(*) FROM notices").fetchone()[0]
    pending_maintenance = conn.execute(
        "SELECT COUNT(*) FROM maintenance WHERE status = 'Pending'"
    ).fetchone()[0]
    conn.close()
    return {
        "total_members": total_members,
        "pending_complaints": pending_complaints,
        "total_complaints": total_complaints,
        "total_notices": total_notices,
        "pending_maintenance": pending_maintenance,
    }
