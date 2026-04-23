import pandas as pd
import random
from sqlalchemy import create_engine, text
import matplotlib.pyplot as plt
from datetime import timedelta

engine = create_engine('postgresql://postgres:password@localhost:5432/shop_db')

def generate_helpdesk_data():
    with engine.connect() as conn:
        conn.execute(text("DROP TABLE IF EXISTS tickets, staff, departments CASCADE;"))
        conn.commit()

    depts = ['IT Support', 'Maintenance', 'Administration', 'Library', 'Academic Affairs']
    pd.DataFrame({'dept_id': range(1, 6), 'name': depts}).to_sql('departments', engine, if_exists='append', index=False)


    staff = [{'staff_id': i, 'full_name': f'Specialist_{i}', 'dept_id': random.randint(1, 5)} for i in range(1, 21)]
    pd.DataFrame(staff).to_sql('staff', engine, if_exists='append', index=False)


    issues = ['Wi-Fi Problem', 'Password Reset', 'Software Install', 'Printer Error', 'Hardware Repair']
    priorities = ['Low', 'Medium', 'High', 'Urgent']
    tickets = []
    
    start_date = pd.to_datetime('2024-01-01')
    
    for i in range(1, 1001):
        created = start_date + timedelta(days=random.randint(0, 200), hours=random.randint(8, 18))
        closed = created + timedelta(hours=random.randint(1, 72)) if random.random() > 0.1 else None
        status = 'Closed' if closed else random.choice(['Open', 'In Progress'])
        
        tickets.append({
            'ticket_id': i,
            'issue_type': random.choice(issues),
            'priority': random.choice(priorities),
            'status': status,
            'created_at': created,
            'closed_at': closed,
            'staff_id': random.randint(1, 20)
        })
    
    pd.DataFrame(tickets).to_sql('tickets', engine, if_exists='append', index=False)
    print("✅ Данные HelpDesk загружены!")

def create_helpdesk_analytics():
    print("Создание графиков...")
    query = """
    SELECT t.*, s.full_name as specialist, d.name as department
    FROM tickets t
    JOIN staff s ON t.staff_id = s.staff_id
    JOIN departments d ON s.dept_id = d.dept_id
    """
    df = pd.read_sql(query, engine)
    df['created_at'] = pd.to_datetime(df['created_at'])
    df['closed_at'] = pd.to_datetime(df['closed_at'])
    
    df['resolution_time'] = (df['closed_at'] - df['created_at']).dt.total_seconds() / 3600

    fig, axes = plt.subplots(2, 2, figsize=(16, 12))
    
    df['weekday'] = df['created_at'].dt.day_name()
    order = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
    df.groupby('weekday').size().reindex(order).plot(kind='bar', ax=axes[0,0], color='orange', title='Tickets by Weekday')

    df.groupby('issue_type').size().sort_values().plot(kind='barh', ax=axes[0,1], color='teal', title='Common Issues')

    df.groupby('status').size().plot(kind='pie', ax=axes[1,0], autopct='%1.1f%%', title='Ticket Statuses')

    df.groupby('priority')['resolution_time'].mean().plot(kind='bar', ax=axes[1,1], color='red', title='Avg Resolution Time (Hours)')

    plt.tight_layout()
    plt.savefig('dashboard.png')
    print("✅ Аналитика готова (dashboard.png)!")

if __name__ == "__main__":
    generate_helpdesk_data()
    create_helpdesk_analytics()