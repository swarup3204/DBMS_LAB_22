#include <stdio.h>
#include <stdlib.h>
#include <postgresql/libpq-fe.h>
#include <string.h>

int main(int argc, char *argv[])
{
    /* Connect to the database */
    PGconn *conn = PQconnectdb("host=127.0.0.1 user=postgres password=abcd dbname=postgres");
    if (PQstatus(conn) != CONNECTION_OK) /*error handling*/
    {
        fprintf(stderr, "Connection to database failed: %s\n", PQerrorMessage(conn));
        PQfinish(conn); // close the connection
        return 1;
    }
    printf("Connected to database\n"); // check and find what are the connection parameters
    /* Close the connection */
    char *query[12]; //     query array
    char ch;         //  to read choice of continuing or not from user
    char *q;         //  to store query of user
    int opt;         //  to read option from user
    /* Filling in queries */
    query[0] = "select T.Name as physician_name from ( select distinct Physician.EmployeeID,Physician.name from Physician,Trained_in,Procedure where Physician.EmployeeID=Trained_in.Physician and Trained_in.Treatment=Procedure.Code and Procedure.Name ilike 'bypass surgery') as T;";
    query[1] = "select T.Name as physician_name from (select distinct Physician.EmployeeID,Physician.name from Physician,Trained_in,Procedure where Physician.EmployeeID=Trained_in.Physician and Trained_in.Treatment=Procedure.Code and Procedure.Name ilike 'bypass surgery') as T,Affiliated_with,Department where T.EmployeeID=Affiliated_with.Physician and Affiliated_with.Department=Department.DepartmentID and Department.Name ilike 'cardiology';";
    query[2] = "select Nurse.Name as nurse_name from Nurse,On_Call,Room where Nurse.EmployeeID=On_Call.Nurse and On_Call.BlockFloor=Room.BlockFloor and On_Call.BlockCode=Room.BlockCode and Room.Number = 123;";
    query[3] = "select T.Name as patient_name,T.Address as patient_address from (select distinct Patient.SSN,Patient.Name,Patient.Address from Patient,Prescribes,Medication where Patient.SSN=Prescribes.Patient and Prescribes.Medication=Medication.Code and Medication.Name ilike 'remdesivir') as T ;";
    query[4] = "select T.name as patient_name,T.InsuranceID as patient_insurance_id from (select distinct Patient.SSN, Patient.Name,Patient.InsuranceID from Patient,Stay,Room where Patient.SSN=Stay.Patient and Stay.Room=Room.Number and Room.Type ilike 'icu' and extract(day from age(Endtime,Start))>15) as T;";
    query[5] = "select T.name as nurse_name from (select distinct Nurse.EmployeeID,Nurse.Name from Nurse,Undergoes,Procedure where Nurse.EmployeeID=Undergoes.AssistingNurse and Undergoes.Procedure=Procedure.Code and Procedure.Name ilike 'bypass surgery') as T";
    query[6] = "select Nurse.Name as nurse_name,Nurse.Position as nurse_position,Physician.Name as physician_name from Nurse,Undergoes,Procedure,Physician where Nurse.EmployeeID=Undergoes.AssistingNurse and Undergoes.Procedure=Procedure.Code and Procedure.Name ilike 'bypass surgery' and Physician.EmployeeID=Undergoes.Physician;";
    query[7] = "select T.name as physician_name from (select distinct Physician.EmployeeID,Physician.Name from Physician,Undergoes where Physician.EmployeeID = Undergoes.Physician and Undergoes.Procedure not in (select Trained_in.Treatment from Physician,Trained_in where Physician.EmployeeID = Trained_in.Physician and Undergoes.Physician=Trained_in.Physician)) as T;";
    query[8] = "select T.name as physician_name from (select distinct Physician.EmployeeID,Physician.Name from Physician,Undergoes where Physician.EmployeeID = Undergoes.Physician and Undergoes.Procedure in (select Trained_in.Treatment from Physician,Trained_in where Physician.EmployeeID = Trained_in.Physician and Undergoes.Physician=Trained_in.Physician and Undergoes.Date > Trained_in.CertificationExpires)) as T;";
    query[9] = "select Physician.Name as physician_name,Procedure.Name as Procedure_name,Undergoes.Date,Patient.Name as patient_name from Physician,Undergoes,Procedure,Patient where Physician.EmployeeID = Undergoes.Physician and Procedure.Code=Undergoes.Procedure and Patient.SSN = Undergoes.Patient and Undergoes.Procedure in (select Trained_in.Treatment from Physician,Trained_in where Physician.EmployeeID = Trained_in.Physician and Undergoes.Physician=Trained_in.Physician and Undergoes.Date>Trained_in.CertificationExpires);";
    query[10] = "select Patient.Name as Patient_name,Physician.Name as Physician_name from Patient,Physician where (Patient.SSN,Patient.PCP) in (select Prescribes.Patient,Prescribes.Physician from Prescribes) and Patient.SSN in (select Undergoes.Patient from Undergoes,Procedure where Undergoes.Procedure=Procedure.Code and Procedure.Cost>5000) and Patient.PCP not in (select Department.Head from Department) and (select count (*) from Appointment,Affiliated_with,Department where Appointment.Physician=Affiliated_with.Physician and Affiliated_with.Department=Department.DepartmentID and Appointment.Patient=Patient.SSN and Department.Name ilike 'cardiology')>=2 and Patient.PCP=Physician.EmployeeID;";
    query[11] = "with med(code,sales) as( select medication.code,count(distinct prescribes.patient) from medication,Prescribes where medication.code=Prescribes.medication group by medication.code) select medication.name as medicine_name,medication.brand as medicine_brand from medication,med where medication.code=med.code and med.sales=(select max(med.sales) from med);";
    do
    {

        printf("Enter the query number you want to execute: "); //  to read option from user
        scanf("%d", &opt);                                      // read option from user
        if (opt < 1 || opt > 13)                                // check if option is valid
        {
            printf("Invalid query number\n");
            continue;
        }
        else
        {
            if (opt == 13) // the 13 the query allows user to enter the procedure name dynamically in the first query
            {
                char *qp1 = "select T.Name as physician_name from ( select distinct Physician.EmployeeID,Physician.name from Physician,Trained_in,Procedure where Physician.EmployeeID=Trained_in.Physician and Trained_in.Treatment=Procedure.Code and Procedure.Name ilike '"; // query part 1
                char *qp2 = "') as T;";                                                                                                                                                                                                                                          // query part 2
                printf("Enter the procedure name to be entered in query 1\n");                                                                                                                                                                                                   // read procedure name from user
                char procedure[30];
                getchar();
                scanf("%[^\n]s", procedure);                                           // take space separated procedure name as input
                q = (char *)malloc(strlen(qp1) + strlen(qp2) + strlen(procedure) + 1); // allocate memory for query
                strcpy(q, qp1);                                                        // copy query part 1
                strcat(q, procedure);                                                  // concat procedure name
                strcat(q, qp2);                                                        // concat query part 2
            }
            else // for other queries
            {
                q = (char *)malloc(strlen(query[opt - 1]) + 1); // allocate memory for query
                strcpy(q, query[opt - 1]);                      // copy query
            }
            PGresult *res = PQexec(conn, q); // execute query

            if (PQresultStatus(res) != PGRES_TUPLES_OK) // check if query failed
            {
                printf("Query failed: %s", PQerrorMessage(conn));
                PQclear(res);
                PQfinish(conn);
                exit(1);
            }
            // print result of query
            int rows = PQntuples(res);
            int cols = PQnfields(res);
            for (int i = 0; i < cols; i++)
            {
                printf("%-30s", PQfname(res, i));
            }
            printf("\n");
            for (int i = 0; i < cols; i++)
            {
                printf("=============================");
            }
            printf("\n");
            for (int i = 0; i < rows; i++)
            {
                for (int j = 0; j < cols; j++)
                {
                    printf("%-30s", PQgetvalue(res, i, j));
                }
                printf("\n");
            }
            PQclear(res);
        }
        free(q);
        printf("Do you want to continue? (y/n): \n");
        getchar();
        scanf("%c", &ch);
    } while (ch == 'y');

    PQfinish(conn);
    return 0;
}
