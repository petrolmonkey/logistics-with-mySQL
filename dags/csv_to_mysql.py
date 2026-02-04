from airflow import DAG
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta
from sqlalchemy import create_engine, text
from airflow.providers.mysql.hooks.mysql import MySqlHook
import pandas as pd
import logging

# # ============================================================================
# # DEFAULT ARGUMENTS
# # ============================================================================

default_args = {
    'owner': 'charlie isra',
    'depends_on_past': False,
    'start_date': datetime(2026,1,28),
    'email': ['charlie.isra@gmail.com'],
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 0,
    'retry_delay': timedelta(minutes=1),
    'execution_timeout': timedelta(minutes=1),
}

# # ============================================================================
# # DAG DEFINITIONS
# # ============================================================================
dag = DAG(
    dag_id='csv_to_mysql',
    default_args=default_args,
    description='Extract CSV shipments data to MySQL',
    schedule='0 2 * * *',  # '@daily' for daily updates or '@hourly' for hourly updates
    catchup=False,
    tags=['logistics', 'etl', 'csv'],
)

# ============================================================================
# PYTHON FUNCTIONS FOR CUSTOM TASKS
# ============================================================================

def check_dbconnection(**context):
    hook = MySqlHook(mysql_conn_id='mysql_asian_imports')
    hook.run('SELECT 1')
    print('MySql connection was successful! Good job Charlie!')

# Extracts from a raw source (e.g., simulated CSV upload to a  /data/raw  folder or API).
def extract_csv():
    headers = ['shipment_id', 'customer_id', 'origin_location_id', 'destination_location_id', 
	'shipment_no', 'mode', 'incoterms', 'planned_ship_date', 'planned_deliver_date','actual_ship_date', 'actual_deliver_date', 'status', 'total_packages', 'total_weight', 
	'weight_uom']
    df = pd.read_csv('/Users/charlie/airflow/data/shipments-pk1.csv',header=None, names=headers)
    batch_id = 'shipments-pk1'
    return df, batch_id

# Validate locations
def valid_locations(engine):
    '''Fetches valid locations from locations table'''
    with engine.connect() as conn:
        result=conn.execute(text('SELECT location_ID FROM locations;'))
        location_id = [row[0] for row in result]
    return location_id

def validate_shipments(df, location_id, batch_id, engine):
    '''Check if location exists, a FK for shipments table.'''

    errors = []

    # FK check before DB
    invalid_loc = ~df['origin_location_id'].isin(location_id)
    if invalid_loc.any():
        df.loc[invalid_loc, 'error_reason'] = 'INVALID_LOCATION'
        errors.append(df[invalid_loc])

    error_df = pd.concat(errors) if errors else df.iloc[0:0]
    clean_df = df[~df.index.isin(error_df.index)]

    if not error_df.empty:
        error_df['batch_id'] = batch_id
        error_df['run_date'] = datetime.now()
        error_df.to_sql('shipment_errors', engine, if_exists='append', index=False)
        logging.error(f'Saved {len(error_df)} errors to shipments_error table in batch {batch_id}')
    logging.info(f'Clean rows loaded: {len(clean_df)}, rows with errors: {len(error_df)}')

    return clean_df, error_df

def load_clean_df(clean_df, engine):
    # Loads into your cleaned schema.
    clean_df.to_sql('shipments', engine, if_exists='append', index=False, method='multi')
    print(f"Loaded {len(clean_df)} rows at {datetime.now()}")

def csv_to_mysql(**context):
    '''
    Full ETL process from CSV, to validation and transformation, then uploads to MySQL database. Data transformation handles empty shipment ids, invalid location IDs (e.g., 9999), invalid dates (e.g., 2025-02-30), and shipments with zero packages/weight. 
    '''
    hook = MySqlHook(mysql_conn_id='mysql_asian_imports')
    engine = hook.get_sqlalchemy_engine()

    df, batch_id = extract_csv()
    location_id = valid_locations(engine)
    clean_df, error_df = validate_shipments(df, location_id, batch_id, engine)

    # Transforms using Python Pandas (in an Airflow task).
    # (logistics example: clean data, convert types, filter invalid)
    clean_df = clean_df.dropna(subset=['shipment_id', 'weight_uom'])
    clean_df = clean_df.drop(columns=['error_reason'])
    # df = df[df['origin_location_id']!=9999]
    clean_df['planned_ship_date'] = pd.to_datetime(clean_df['planned_ship_date'], errors='coerce')
    clean_df['planned_deliver_date'] = pd.to_datetime(clean_df['planned_deliver_date'], errors='coerce')
    clean_df['actual_ship_date'] = pd.to_datetime(clean_df['actual_ship_date'], errors='coerce')
    clean_df['actual_deliver_date'] = pd.to_datetime(clean_df['actual_deliver_date'], errors='coerce')
    df = df[df['total_weight'] > 0]  # Business rule: valid weights

    load_clean_df(clean_df, engine)

    # Data quality metrics
    print(f"ETL Summary: {len(df)} raw → {len(clean_df)} valid, {len(error_df)} rejected")
    context['ti'].xcom_push(key='rows_loaded', value=len(clean_df))
    context['ti'].xcom_push(key='rows_rejected', value=len(error_df)) 


# # ============================================================================
# # TASK DEFINITIONS
# # ============================================================================
t1_check_dbconnection = PythonOperator(
    task_id='check_dbconnection',
    python_callable=check_dbconnection,
    provide_context=True,
    dag=dag
)

t2_run_etl = PythonOperator(
    task_id='csv_to_mysql',
    python_callable=csv_to_mysql,
    provide_context=True,
    dag=dag
)

# ============================================================================
# TASK DEPENDENCIES
# ============================================================================
# First, check database connection
t1_check_dbconnection >> t2_run_etl


# ============================================================================
# DAG DOCUMENTATION
# ============================================================================
dag.doc_md = """
# Logistics Asian Imports ETL Pipeline

## Overview
This DAG orchestrates the daily ETL process for the `asian_imports` logistics database.

## Tasks
1. **check_database_connectivity**: Validates MySQL connection
2. **extract_shipments_data**: Extracts new shipments from csv

## Schedule
- **Frequency**: Daily
- **Time**: 2:00 AM UTC
- **Timezone**: UTC

## MySQL Connection
- **Connection ID**: mysql_asian_imports
- **Schema**: asian_imports
- **Host**: [Set in Airflow Connections]
- **Port**: 3306

## Setup Requirements
1. Create MySQL connection in Airflow UI with connection ID `mysql_asian_imports`
2. Ensure MySQL user has SELECT permissions on `asian_imports` schema
3. Set AIRFLOW_HOME=/Users/name/airflow in your environment

## Monitoring
- Failed tasks will trigger email alerts
- Check Airflow for task logs 
- Review DAG runs history for performance metrics

## Notes
- DAG respects UTC timezone for scheduling
- Catchup is disabled; backfilling must be done manually
- Maximum 1 concurrent DAG run to prevent database locks
"""