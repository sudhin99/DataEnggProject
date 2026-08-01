from airflow import DAG
from airflow.operators.email import EmailOperator
from datetime import datetime
# Define default arguments
default_args = {
 'owner': 'airflow',
 'start_date': datetime(2024, 1, 1),
 'email_on_failure': False,
 'email_on_retry': False
}

# Create DAG
with DAG(
 dag_id='send_email_example',
 default_args=default_args,
 schedule=None, # Run manually
 catchup=False
) as dag:

 send_email = EmailOperator(
 task_id='send_email_task',
 to='pritambose1994t@gmail.com', # Change to actual recipient
 subject='Test Email from Airflow',
 html_content="""
 <h3>Hello from Airflow 👋</h3>
 <p>This is a test email sent using <b>EmailOperator</b>.</p>
 """,
 )

 send_email