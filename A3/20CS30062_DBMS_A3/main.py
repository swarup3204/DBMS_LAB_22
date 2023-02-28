#!/usr/bin/python
import psycopg2         # install psycopg2 using pip install psycopg2
from tabulate import tabulate # install tabulate using pip install tabulate


def connect():
    """ Connect to the PostgreSQL database server """
    conn = None
    try:
        # read connection parameters

        # connect to the PostgreSQL server
        print('Connecting to the PostgreSQL database...')
        conn = psycopg2.connect(host="localhost",
                                database="postgres",
                                user="postgres",
                                password="abcd")

        # create a cursor
        cur = conn.cursor()

        # execute a statement
        print('PostgreSQL database version:')
        cur.execute('SELECT version()')

        # display the PostgreSQL database server version
        db_version = cur.fetchone()
        print(db_version)
        
        
        # populate array of 12 queries to execute
        queries = [None] * 12
        queries[0] = "select T.Name as physician_name from ( select distinct Physician.EmployeeID,Physician.name from Physician,Trained_in,Procedure where Physician.EmployeeID=Trained_in.Physician and Trained_in.Treatment=Procedure.Code and Procedure.Name ilike 'bypass surgery') as T;";
        queries[1] = "select T.Name as physician_name from (select distinct Physician.EmployeeID,Physician.name from Physician,Trained_in,Procedure where Physician.EmployeeID=Trained_in.Physician and Trained_in.Treatment=Procedure.Code and Procedure.Name ilike 'bypass surgery') as T,Affiliated_with,Department where T.EmployeeID=Affiliated_with.Physician and Affiliated_with.Department=Department.DepartmentID and Department.Name ilike 'cardiology';";
        queries[2] = "select Nurse.Name as nurse_name from Nurse,On_Call,Room where Nurse.EmployeeID=On_Call.Nurse and On_Call.BlockFloor=Room.BlockFloor and On_Call.BlockCode=Room.BlockCode and Room.Number = 123;";
        queries[3] = "select T.Name as patient_name,T.Address as patient_address from (select distinct Patient.SSN,Patient.Name,Patient.Address from Patient,Prescribes,Medication where Patient.SSN=Prescribes.Patient and Prescribes.Medication=Medication.Code and Medication.Name ilike 'remdesivir') as T ;";
        queries[4] = "select T.name as patient_name,T.InsuranceID as patient_insurance_id from (select distinct Patient.SSN, Patient.Name,Patient.InsuranceID from Patient,Stay,Room where Patient.SSN=Stay.Patient and Stay.Room=Room.Number and Room.Type ilike 'icu' and extract(day from age(Endtime,Start))>15) as T;";
        queries[5] = "select T.name as nurse_name from (select distinct Nurse.EmployeeID,Nurse.Name from Nurse,Undergoes,Procedure where Nurse.EmployeeID=Undergoes.AssistingNurse and Undergoes.Procedure=Procedure.Code and Procedure.Name ilike 'bypass surgery') as T ;";
        queries[6] = "select Nurse.Name as nurse_name,Nurse.Position as nurse_position,Physician.Name as physician_name from Nurse,Undergoes,Procedure,Physician where Nurse.EmployeeID=Undergoes.AssistingNurse and Undergoes.Procedure=Procedure.Code and Procedure.Name ilike 'bypass surgery' and Physician.EmployeeID=Undergoes.Physician;";
        queries[7] = "select T.name as physician_name from (select distinct Physician.EmployeeID,Physician.Name from Physician,Undergoes where Physician.EmployeeID = Undergoes.Physician and Undergoes.Procedure not in (select Trained_in.Treatment from Physician,Trained_in where Physician.EmployeeID = Trained_in.Physician and Undergoes.Physician=Trained_in.Physician)) as T;";
        queries[8] = "select T.name as physician_name from (select distinct Physician.EmployeeID,Physician.Name from Physician,Undergoes where Physician.EmployeeID = Undergoes.Physician and Undergoes.Procedure in (select Trained_in.Treatment from Physician,Trained_in where Physician.EmployeeID = Trained_in.Physician and Undergoes.Physician=Trained_in.Physician and Undergoes.Date > Trained_in.CertificationExpires)) as T;";
        queries[9] = "select Physician.Name as physician_name,Procedure.Name as Procedure_name,Undergoes.Date,Patient.Name as patient_name from Physician,Undergoes,Procedure,Patient where Physician.EmployeeID = Undergoes.Physician and Procedure.Code=Undergoes.Procedure and Patient.SSN = Undergoes.Patient and Undergoes.Procedure in (select Trained_in.Treatment from Physician,Trained_in where Physician.EmployeeID = Trained_in.Physician and Undergoes.Physician=Trained_in.Physician and Undergoes.Date>Trained_in.CertificationExpires);";
        queries[10] = "select Patient.Name as Patient_name,Physician.Name as Physician_name from Patient,Physician where (Patient.SSN,Patient.PCP) in (select Prescribes.Patient,Prescribes.Physician from Prescribes) and Patient.SSN in (select Undergoes.Patient from Undergoes,Procedure where Undergoes.Procedure=Procedure.Code and Procedure.Cost>5000) and Patient.PCP not in (select Department.Head from Department) and (select count (*) from Appointment,Affiliated_with,Department where Appointment.Physician=Affiliated_with.Physician and Affiliated_with.Department=Department.DepartmentID and Appointment.Patient=Patient.SSN and Department.Name ilike 'cardiology')>=2 and Patient.PCP=Physician.EmployeeID;";
        queries[11] = "with med(code,sales) as( select medication.code,count(distinct prescribes.patient) from medication,Prescribes where medication.code=Prescribes.medication group by medication.code) select medication.name as medicine_name,medication.brand as medicine_brand from medication,med where medication.code=med.code and med.sales=(select max(med.sales) from med);"; 
        
        # execute the queries as a menu driven program taking query number as user choice
        while True:
            print("Enter 1 to 13 to execute the corresponding query or 0 to exit")
            choice = int(input())
            if choice == 0:
                break
            elif choice >= 1 and choice <= 12:
                # get output along with column names and print in tabular format
                cur.execute(queries[choice-1])
                # extract column names from cur.description
                col_names = [desc[0] for desc in cur.description]
                # print output formatted as a table with column names fetched from result set
                print(tabulate(cur.fetchall(), headers=col_names, tablefmt='psql'))
            elif choice == 13:
                # allow user to enter procedure name for query 1 of his choice
                print("Enter procedure name")
                proc_name = input()
                # get part 1 of query 1
                qp1 = "select T.Name as physician_name from ( select distinct Physician.EmployeeID,Physician.name from Physician,Trained_in,Procedure where Physician.EmployeeID=Trained_in.Physician and Trained_in.Treatment=Procedure.Code and Procedure.Name ilike '"
                qp2 = "') as T;"
                # concat qp1,proc_name and qp2 to get the final query
                query = qp1 + proc_name + qp2
                # execute the query
                cur.execute(query)
                # extract column names from cur.description
                col_names = [desc[0] for desc in cur.description]
                # print output formatted as a table with column names fetched from result set
                print(tabulate(cur.fetchall(), headers=col_names, tablefmt='psql'))
            else:
                print("Invalid choice")

        # close the communication with the PostgreSQL
        cur.close()
    except (Exception, psycopg2.DatabaseError) as error:
        print(error)
    finally:
        if conn is not None:
            conn.close()
            print('Database connection closed.')


if __name__ == '__main__':
    connect()
