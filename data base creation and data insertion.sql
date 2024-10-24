create schema customers;
create schema services;
create schema resources;



create table resources.cities(
	cityCode varchar(4) primary key,
	City varchar(16) not null,
	ZipCode varchar(5) not null,
	CityPopulation int not null,
	CityArea float not null,
	InternetCoverage tinyint not null,
	AverageIncome int not null,
	UsersNumber int not null,
	Coverage5G bit not null
);

create table customers.customersInfo(
	CustomerID varchar(12) primary key,
	Gender varchar(6) not null,
	Age int not null,
	HasPartner bit not null,
	Dependents bit not null,
	CityCode varchar(4) not null,
	foreign key (CityCode) references resources.cities(cityCode)
);

create table services.InternetPlans(
	INternetPlan nvarchar(50) primary key,
	OnlineSecurity bit not null,
	OnlineBackup bit not null,
	DeviceProtection bit not null,
	Techsupport bit not null,
	StreamingTV bit not null,
	StreamingMovies bit not null
)

create table services.charges(
	ChargesID int identity(1,1) primary key,
	Tenure int not null,
	MonthlyCharges float not null,
	TotalCharges float null,
);

create table services.serviceInfo(
	ServiceID int identity(1,1) primary key,
	PhoneService bit null,
	MultipleLines bit null,
	InternetService nvarchar(50) null,
	InternetPlan nvarchar(50) null,
	ChargesID int,
	foreign key (InternetPlan) references services.InternetPlans(INternetPlan),
	foreign key (ChargesID) references services.charges(ChargesID),
);

create table services.contractInfo(
	ContractID int identity(1,1)primary key,
	CustomerID varchar(12) ,
	ContractInfo nvarchar(50) not null,
	PaperlessBilling bit not null,
	PaymentMethod nvarchar(50) not null,
	ServiceID int,
	Churn bit not null,
	foreign key (ServiceID) references services.serviceInfo(ServiceID),
	foreign key (CustomerID) references customers.customersInfo(CustomerID)
);


drop table services.contractInfo; 
drop table services.serviceInfo; 
drop table services.charges; 
drop table services.InternetPlans; 
drop table customers.customersInfo; 
drop table resources.cities;




















INSERT INTO resources.cities (City, ZipCode, CityCode, CityPopulation, CityArea, InternetCoverage, AverageIncome, UsersNumber, Coverage5G)
SELECT city, zip_code, city_code, population, area_sq_miles, internet_coverage, average_income, number_of_users, 5G_coverage
FROM dbo.cities;

INSERT INTO services.InternetPlans (InternetPlan, OnlineSecurity, OnlineBackup, DeviceProtection, TechSupport, StreamingTV, StreamingMovies)
SELECT bundle, OnlineSecurity, OnlineBackup, DeviceProtection, TechSupport, StreamingTV, StreamingMovies
FROM dbo.plans;

INSERT INTO customers.customersInfo (CustomerID, Gender, Age, HasPartner, Dependents, CityCode)
SELECT customerID, gender, age, Partner, Dependents, city_code
FROM dbo.Telco_extended_5aleth;

INSERT INTO services.charges (Tenure, MonthlyCharges, TotalCharges)
SELECT tenure, MonthlyCharges, TotalCharges
FROM dbo.Telco_extended_5aleth;


INSERT INTO services.serviceInfo (PhoneService, MultipleLines, InternetService, InternetPlan)
SELECT PhoneService, MultipleLines, InternetService, bundle
FROM dbo.Telco_extended_5aleth;

UPDATE services.serviceInfo SET ChargesID = ServiceID;

INSERT INTO services.contractInfo (CustomerID, ContractInfo, PaperlessBilling, PaymentMethod, Churn)
SELECT customerID, tenure, PaperlessBilling, PaymentMethod, Churn
FROM dbo.Telco_extended_5aleth;

UPDATE services.contractInfo SET ServiceID = ContractID;





--Count total number of customers
SELECT COUNT(*) AS TotalCustomers FROM customers.customersInfo;

--Average monthly charges across all customers
SELECT AVG(MonthlyCharges) AS AverageMonthlyCharges FROM services.charges;

--Total charges for all customers
SELECT SUM(TotalCharges) AS TotalRevenue FROM services.charges;

--Count customers with 5G coverage by city
SELECT c.City, COUNT(ci.CustomerID) AS CustomersWith5G
FROM customers.customersInfo ci
JOIN resources.cities c ON ci.CityCode = c.cityCode
WHERE c.Coverage5G = 1
GROUP BY c.City;

--Percentage of customers who have churned
SELECT 
    (SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)) AS ChurnPercentage
FROM services.contractInfo;

--Average income per city
SELECT City, AVG(AverageIncome) AS AverageIncome
FROM resources.cities
GROUP BY City;


--Distribution of customers by age group
SELECT 
    CASE 
        WHEN Age < 18 THEN 'Under 18'
        WHEN Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN Age BETWEEN 31 AND 50 THEN '31-50'
        ELSE 'Above 50'
    END AS AgeGroup, 
    COUNT(CustomerID) AS NumberOfCustomers
FROM customers.customersInfo
GROUP BY 
    CASE 
        WHEN Age < 18 THEN 'Under 18'
        WHEN Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN Age BETWEEN 31 AND 50 THEN '31-50'
        ELSE 'Above 50'
    END;


--Cities with the largest population
SELECT City, CityPopulation
FROM resources.cities
ORDER BY CityPopulation DESC;


--Count of customers by gender
SELECT Gender, COUNT(*) AS NumberOfCustomers
FROM customers.customersInfo
GROUP BY Gender;


