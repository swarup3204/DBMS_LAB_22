import java.util.Scanner;
import java.sql.*;

// open in vscode and run as java
public class main {
    public static void main(String[] args) {
        Connection conn = null;
        try {
            Class.forName("org.postgresql.Driver");
            conn = DriverManager.getConnection(
                    "jdbc:postgresql://localhost:5432/postgres",
                    "postgres",
                    "abcd");
        } catch (Exception e) {
            System.err.println("Could not connect to the database");
            e.printStackTrace();
        }
        Scanner sc = new Scanner(System.in);
        int queryNum;
        // write all queries in an array of character pointets
        String[] queries = new String[12];
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
        String choice;
        do {
            System.out.println("Enter the query number (1-13): ");
            queryNum = sc.nextInt();
            if (queryNum > 0 && queryNum < 14) {
                try {
                    Statement stmt = conn.createStatement();
                    ResultSet rs;
                    ResultSetMetaData rsmd;
                    if (queryNum == 13)
                    {
                        // allow user input for procedure name of first query
                        System.out.println("Enter the procedure name: ");
                        //flush the buffer
                        sc.nextLine();
                        String procedureName = sc.nextLine();
                        // get first part of query in a string
                        String p1="select T.Name as physician_name from ( select distinct Physician.EmployeeID,Physician.name from Physician,Trained_in,Procedure where Physician.EmployeeID=Trained_in.Physician and Trained_in.Treatment=Procedure.Code and Procedure.Name ilike '";
                        // get second part of query in a string
                        String p2="') as T;";
                        // now concatentate p1,procedureName and p2
                        String query=p1+procedureName+p2;
                        // System.out.println("Query: "+query);
                        rs = stmt.executeQuery(query);
                        rsmd = rs.getMetaData();
                    }   
                    else
                    {
                    // get the result and print in tabular form
                        rs = stmt.executeQuery(queries[queryNum - 1]);
                        rsmd = rs.getMetaData();
                    }
                    int columnsNumber = rsmd.getColumnCount();
                    // print result in tabular form,first print the column names
                    for (int i = 1; i <= columnsNumber; i++) {
                        if (i > 1)
                            System.out.print("  ");
                        String columnName = rsmd.getColumnName(i);
                        // print output of 30 characters width
                        System.out.printf("%-30s", columnName);
                    }
                    // print dashes as big as number of columns
                    System.out.println("");
                    for (int i = 1; i <= columnsNumber; i++) {
                        if (i > 1)
                            System.out.print("  ");
                        System.out.print("------------------------------");
                    }
                    // now print the rows
                    System.out.println("");
                    while (rs.next()) {
                        for (int i = 1; i <= columnsNumber; i++) {
                            if (i > 1)
                                System.out.print("  ");
                            String columnValue = rs.getString(i);
                            System.out.printf("%-30s",columnValue);
                        }
                        System.out.println("");
                    }
                    
                    // while (rs.next()) {
                    //     for (int i = 1; i <= columnsNumber; i++) {
                    //         if (i > 1)
                    //             System.out.print(",  ");
                    //         String columnValue = rs.getString(i);
                    //         System.out.print(columnValue + " " + rsmd.getColumnName(i));
                    //     }
                    //     System.out.println("");
                    // }
                } catch (Exception e) {
                    System.err.println("Could not execute query");
                    e.printStackTrace();
                }
            } else {
                System.out.println("Invalid query number");
            }
            System.out.println("Do you want to continue? (y/n)");
            choice = sc.next();
        } while (choice.equals("y"));
        sc.close();
    }
}
