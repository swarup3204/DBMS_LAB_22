create table if not exists Physician(
	EmployeeID int not null,
	Name text not null,
	Position text not null,
	SSN int not null,
	primary key (EmployeeID));

create table if not exists Department(
	DepartmentID int not null,
	Name text not null,
	Head int not null,
	primary key (DepartmentID),
	foreign key (Head) references Physician);
	

create table if not exists Affiliated_with(
	Physician int not null,
	Department int not null,
	PrimaryAffiliation boolean not null,
	primary key (Physician,Department),
	foreign key (Physician) references Physician,
	foreign key (Department) references Department);
	
	
create table if not exists Patient(
	SSN int not null,
	Name text not null,
	Address text not null,
	Phone text not null,
	InsuranceID int not null,
	PCP int not null,
	primary key (SSN),
	foreign key (PCP) references Physician);
	
create table if not exists Procedure(
	Code int not null,
	Name text not null,
	Cost int not null,
	primary key (Code));	
	
create table if not exists Block(
	Floor int not null,
	Code int not null,
	primary key (Floor,Code));

create table if not exists Room(
	Number int not null,
	Type text not null,
	BlockFloor int not null,
	BlockCode int not null,
	Unavailable boolean not null,
	primary key (Number),
	foreign key (BlockFloor,BlockCode) references Block(Floor,Code));
	
create table if not exists Stay(
	StayID int not null,
	Patient int not null,
	Room int not null,
	Start timestamp not null,
	Endtime timestamp not null,
	primary key (StayID),
	foreign key (Patient) references Patient,
	foreign key (Room) references Room);

create table if not exists Nurse(
	EmployeeID int not null,
	Name text not null,
	Position text not null,
	Registered boolean not null,
	SSN int not null,
	primary key (EmployeeID));

create table if not exists Appointment(
	AppointmentID int not null,
	Patient int not null,
	PrepNurse int,
	Physician int not null,
	Start timestamp not null,
	Endtime timestamp not null,
	ExaminationRoom text not null,
	primary key (AppointmentID),
	foreign key (Patient) references  Patient,
	foreign key (PrepNurse) references  Nurse,
	foreign key (Physician) references  Physician);
	
create table if not exists Medication(
	Code int not null,
	Name text not null,
	Brand text not null,
	Description text not null,
	primary key (Code));
	
create table if not exists Trained_in(
	Physician int not null,
	Treatment int not null,
	CertificationDate timestamp not null,
	CertificationExpires timestamp not null,
	primary key (Physician,Treatment),
	foreign key (Physician) references Physician,
	foreign key (Treatment) references Procedure);

create table if not exists Prescribes(
	Physician int not null,
	Patient int not null,
	Medication int not null, 
	Date timestamp not null,
	Appointment int,
	Dose text not null,
	primary key(Physician,Patient,Medication,Date),
	foreign key(Physician) references Physician,
	foreign key(Patient) references Patient,
	foreign key(Medication) references Medication,
	foreign key(Appointment) references Appointment);

create table if not exists On_Call(
	Nurse int not null,
	BlockFloor int not null,
	BlockCode int not null,
	Start timestamp not null,
	Endtime timestamp not null,
	primary key (Nurse,BlockFloor,BlockCode,Start,Endtime),
	foreign key (Nurse) references Nurse,
	foreign key (BlockFloor,BlockCode) references Block);
	
create table if not exists Undergoes(
	Patient int not null,
	Procedure int not null,
	Stay int not null,
	Date timestamp not null,
	Physician int not null,
	AssistingNurse int,
	primary key (Patient,Procedure,Stay,Date),
	foreign key (Patient) references Patient,
	foreign key (Procedure) references Procedure,
	foreign key (Stay) references Stay,
	foreign key (AssistingNurse) references Nurse,
	foreign key (Physician) references Physician);
	
-- \dt+

INSERT INTO Physician VALUES(1,'Anubhav','Staff Intern',111111111);
INSERT INTO Physician VALUES(2,'Swanand','Senior Physician',444444444);
INSERT INTO Physician VALUES(3,'Chinmay','Assistant Physician',787192087);
INSERT INTO Physician VALUES(4,'Daman','Assistant Physician',555555555);
INSERT INTO Physician VALUES(5,'Faizan','Assistant Physician',666666666);
INSERT INTO Physician VALUES(6,'Anand','Senior Physician',101010101);

INSERT INTO Procedure VALUES(1,'bypass surgery',7000);
INSERT INTO Procedure VALUES(2,'open heart surgery',10000);
INSERT INTO Procedure VALUES(3,'stone removal',8000);
INSERT INTO Procedure VALUES(4,'amputation',3000);

INSERT INTO Block VALUES(1,1);
INSERT INTO Block VALUES(1,2);
INSERT INTO Block VALUES(2,1);
INSERT INTO Block VALUES(2,2);
INSERT INTO Block VALUES(3,1);
INSERT INTO Block VALUES(1,3);
INSERT INTO Block VALUES(3,2);
INSERT INTO Block VALUES(2,3);
INSERT INTO Block VALUES(4,4);
INSERT INTO Block VALUES(5,4);

INSERT INTO Medication VALUES(1,'remdesivir','Deserem','for covid treatment');
INSERT INTO Medication VALUES(2,'paracetamol','Dosolom','for curing common cold');
INSERT INTO Medication VALUES(3,'cetrizine','Cephla','for curing allergies');

INSERT INTO Nurse VALUES(1,'Reema','Senior nurse','t',222333444);
INSERT INTO Nurse VALUES(2,'Shreya','Trainee nurse','f',242323434);
INSERT INTO Nurse VALUES(3,'Madhvi','Assistant nurse','t',111212111);
INSERT INTO Nurse VALUES(4,'Rani','Head nurse','t',545454545);

INSERT INTO Department VALUES(1,'cardiology',3);
INSERT INTO Department VALUES(2,'neurology',4);
INSERT INTO Department VALUES(3,'endocrinology',5);

INSERT INTO Patient VALUES(777888999,'Anuj','Ranchi','9179333444',78,1);
INSERT INTO Patient VALUES(888112244,'Aritra','Delhi','9279445533',89,2);
INSERT INTO Patient VALUES(333111000,'Dinesh','Roorkee','8789444333',98,1);
INSERT INTO Patient VALUES(222221111,'Dinesh','Jamshedpur','7777555522',112,2);

INSERT INTO Room VALUES(123,'cabin',1,2,'f');
INSERT INTO Room VALUES(124,'ccu',1,2,'t');
INSERT INTO Room VALUES(231,'ccu',2,3,'f');
INSERT INTO Room VALUES(324,'icu',3,2,'t');
INSERT INTO Room VALUES(443,'icu',4,4,'f');
INSERT INTO Room VALUES(543,'icu',5,4,'f');

INSERT INTO Appointment VALUES(1,777888999,3,1,'2023-01-10 08:00','2023-01-10 09:00','Cabin');
INSERT INTO Appointment VALUES(2,333111000,null,2,'2023-01-11 09:00','2023-01-11 10:00','Cabin');
INSERT INTO Appointment VALUES(3,333111000,2,4,'2023-01-15 08:00','2023-01-15 09:00','Cabin');
INSERT INTO Appointment VALUES(4,888112244,null,6,'2023-01-20 10:00','2023-01-20 11:00','Cabin');
INSERT INTO Appointment VALUES(5,888112244,4,3,'2023-01-21 11:00','2023-01-21 12:00','Cabin');

INSERT INTO On_Call VALUES(1,1,2,'2023-01-26 05:00','2023-01-26 07:00');
INSERT INTO On_Call VALUES(2,2,1,'2023-01-27 08:00','2023-01-27 11:00');
INSERT INTO On_Call VALUES(3,1,2,'2023-01-27 12:00','2023-01-27 13:00');
INSERT INTO On_Call VALUES(4,1,2,'2023-01-28 14:00','2023-01-28 16:00');

INSERT INTO Trained_in VALUES(1,1,'2023-01-01','2023-12-31');
INSERT INTO Trained_in VALUES(2,1,'2023-01-01','2023-12-31');
INSERT INTO Trained_in VALUES(3,3,'2023-01-01','2023-12-31');
INSERT INTO Trained_in VALUES(4,2,'2023-01-01','2023-12-31');
INSERT INTO Trained_in VALUES(5,2,'2022-01-01','2022-12-31');
INSERT INTO Trained_in VALUES(6,1,'2022-01-01','2022-12-31');
INSERT INTO Trained_in VALUES(5,4,'2023-01-01','2023-12-31');

INSERT INTO Affiliated_With VALUES(3,1,'t');
INSERT INTO Affiliated_With VALUES(4,2,'t');
INSERT INTO Affiliated_With VALUES(5,3,'t');
INSERT INTO Affiliated_With VALUES(2,1,'t');
INSERT INTO Affiliated_With VALUES(1,1,'t');
INSERT INTO Affiliated_With VALUES(6,1,'t');
INSERT INTO Affiliated_With VALUES(6,2,'f');

INSERT INTO Stay VALUES(1,888112244,231,'2023-01-10','2023-01-15');
INSERT INTO Stay VALUES(2,888112244,324,'2023-01-01','2023-01-17');
INSERT INTO Stay VALUES(3,777888999,443,'2023-01-02','2023-01-10');
INSERT INTO Stay VALUES(4,777888999,443,'2023-01-11','2023-01-28');
INSERT INTO Stay VALUES(5,222221111,543,'2023-01-06','2023-01-20');
INSERT INTO Stay VALUES(6,333111000,123,'2023-01-08','2023-01-23');

INSERT INTO Prescribes VALUES(1,777888999,1,'2023-01-10',1,'5');
INSERT INTO Prescribes VALUES(2,333111000,2,'2023-01-11',2,'3');
INSERT INTO Prescribes VALUES(1,333111000,1,'2023-01-15',3,'3');
INSERT INTO Prescribes VALUES(2,888112244,2,'2023-01-20',4,'5');
INSERT INTO Prescribes VALUES(3,888112244,2,'2023-01-21',5,'2');
INSERT INTO Prescribes VALUES(3,888112244,1,'2023-01-31',null,'2');

INSERT INTO Undergoes VALUES(888112244,1,1,'2023-01-12',1,1);
INSERT INTO Undergoes VALUES(222221111,4,5,'2023-01-17',4,3);
INSERT INTO Undergoes VALUES(333111000,3,6,'2023-01-10',5,null);
INSERT INTO Undergoes VALUES(777888999,1,4,'2023-01-14',6,1);
INSERT INTO Undergoes VALUES(777888999,2,3,'2023-01-07',5,2);
-- \dt+

-- table Affiliated_with;
-- table Nurse;
-- table Physician;
-- table Procedure;
-- table Patient;
-- table Trained_in;
-- table Undergoes;
-- table Room;
-- table On_Call;
-- table Appointment;
-- table Medication;
-- table Prescribes;
-- table Stay;
-- table Block;
-- table Department;

/*Q1 Chance of duplicates*/
select T.Name as physician_name
from(
  select distinct Physician.EmployeeID,Physician.name
	from Physician,Trained_in,Procedure
	where Physician.EmployeeID=Trained_in.Physician and 
	      Trained_in.Treatment=Procedure.Code and
	      Procedure.Name ilike 'bypass surgery') as T
	      ;

/*Q2 Chance of duplicates*/
select T.Name as physician_name
	from (select distinct Physician.EmployeeID,Physician.name
	      from Physician,Trained_in,Procedure
	      where Physician.EmployeeID=Trained_in.Physician and 
	      Trained_in.Treatment=Procedure.Code and
	      Procedure.Name ilike 'bypass surgery') as T,Affiliated_with,Department
	where T.EmployeeID=Affiliated_with.Physician
	      and Affiliated_with.Department=Department.DepartmentID and Department.Name ilike 'cardiology';

/*Q3,assume that if nurse in charge of block and floor same as 123 then surely visited 123,it's not correct*/   
select Nurse.Name as nurse_name
	from Nurse,On_Call,Room
	where Nurse.EmployeeID=On_Call.Nurse and On_Call.BlockFloor=Room.BlockFloor
		  and On_Call.BlockCode=Room.BlockCode and Room.Number = 123;
	     

/*Q4 Chance of duplicates*/	      
select T.Name as patient_name,T.Address as patient_address
from(
select distinct Patient.SSN,Patient.Name,Patient.Address
	from Patient,Prescribes,Medication
	where Patient.SSN=Prescribes.Patient and Prescribes.Medication=Medication.Code
	      and Medication.Name ilike 'remdesivir') as T
	      ;

/*Q5 Chance of duplicates*/
select T.name as patient_name,T.InsuranceID as patient_insurance_id
from(
select distinct Patient.SSN,	Patient.Name,Patient.InsuranceID
	from Patient,Stay,Room
	where Patient.SSN=Stay.Patient and Stay.Room=Room.Number
	      and Room.Type ilike 'icu' 
	      and extract(day from age(Endtime,Start))>15) as T;

/*Q6--chance of duplicates*/	      
select T.name as nurse_name
from(
select distinct Nurse.EmployeeID,Nurse.Name
	from Nurse,Undergoes,Procedure
	where Nurse.EmployeeID=Undergoes.AssistingNurse and 
	      Undergoes.Procedure=Procedure.Code
	      and Procedure.Name ilike 'bypass surgery') as T ;
	
/*Q7 - duplicate handling not done*/     
select Nurse.Name as nurse_name,Nurse.Position as nurse_position,Physician.Name as physician_name
	from Nurse,Undergoes,Procedure,Physician
	where Nurse.EmployeeID=Undergoes.AssistingNurse and 
	      Undergoes.Procedure=Procedure.Code
	      and Procedure.Name ilike 'bypass surgery'
	      and Physician.EmployeeID=Undergoes.Physician;
-- /Q8-alter*/	      
-- select Physician.Name as physician_name
--   from Physician,Undergoes
--   	where Physician.EmployeeID = Undergoes.Physician 
--   			and not exists 	(select * 
--   	      				   from Physician,Trained_in
--   	      				   where Physician.EmployeeID =  Trained_in.Physician and Physician.EmployeeID = Undergoes.Physician and Undergoes.Procedure=Trained_in.Treatment);
	
/*Q8,chance of repeated Physician name display*/	
select T.name as physician_name
from(
select distinct Physician.EmployeeID,Physician.Name
  	from Physician,Undergoes
  	where Physician.EmployeeID = Undergoes.Physician and 
  	Undergoes.Procedure not in (select Trained_in.Treatment 
  	      				   from Physician,Trained_in
  	      				   where Physician.EmployeeID = Trained_in.Physician and Undergoes.Physician=Trained_in.Physician)) as T;
  	 
/*Q9,chance of repeated Physicians*/     			
select T.name as physician_name
from(
select distinct Physician.EmployeeID,Physician.Name
  	from Physician,Undergoes
  	where Physician.EmployeeID = Undergoes.Physician and 
  	Undergoes.Procedure in	   (select Trained_in.Treatment 
  	      				   from Physician,Trained_in
  	      				   where Physician.EmployeeID = Trained_in.Physician and Undergoes.Physician=Trained_in.Physician and Undergoes.Date > Trained_in.CertificationExpires)) as T;
  	      				 
/*Q10,more data included so repeated Physician data ok no de duplication*/  
select Physician.Name as physician_name,Procedure.Name as Procedure_name,Undergoes.Date,Patient.Name as patient_name
 	from Physician,Undergoes,Procedure,Patient
 	where Physician.EmployeeID = Undergoes.Physician and Procedure.Code=Undergoes.Procedure and Patient.SSN = Undergoes.Patient and Undergoes.Procedure
 		in	   (select Trained_in.Treatment 
  	      				   from Physician,Trained_in
  	      				   where Physician.EmployeeID = Trained_in.Physician and Undergoes.Physician=Trained_in.Physician and Undergoes.Date>Trained_in.CertificationExpires);  

/*Q11*/
select Patient.Name as Patient_name,Physician.Name as Physician_name
     	from Patient,Physician
     	where (Patient.SSN,Patient.PCP) in (select Prescribes.Patient,Prescribes.Physician
     						      from Prescribes)
           and Patient.SSN in (select Undergoes.Patient
           			from Undergoes,Procedure
           			where Undergoes.Procedure=Procedure.Code and Procedure.Cost>5000)
           and Patient.PCP not in (select Department.Head
           			   from Department)
           and 	    (select count (*)
           	     from Appointment,Affiliated_with,Department
           	     where Appointment.Physician=Affiliated_with.Physician 
           	          and Affiliated_with.Department=Department.DepartmentID 
           	          and Appointment.Patient=Patient.SSN 
           	          and Department.Name ilike 'cardiology')>=2
           	     
           and Patient.PCP=Physician.EmployeeID;
        
/*rephrase question as name and brand of medication prescribed maximum number of times*/
/*Q12*/
with med(code,sales) as
( select medication.code,count(distinct prescribes.patient)
  from medication,Prescribes
  where medication.code=Prescribes.medication
  group by medication.code
)
select medication.name as medicine_name,medication.brand as medicine_brand
from medication,med
where medication.code=med.code and med.sales=(select max(med.sales) from med);