# Sales-Data-Analysis
Analyze sales data and provide actionable insights to drive strategic business decisions at Northwind Traders

Throughout the project, we will construct intricate SQL queries to calculate metrics, rank data, and discern trends. Our insights will empower management to make data-informed decisions, enhancing productivity, optimizing inventory and marketing strategies, monitoring company progress, and identifying high-value customers.

The projects focus on:

-Evaluating employee performance to boost productivity,
-Understanding product sales and category performance to optimize inventory and marketing strategies,
-Analyzing sales growth to identify trends, monitor company progress, and make more accurate forecasts,
-And evaluating customer purchase behavior to target high-value customers with promotional incentives.

_Database schema_
![image](https://github.com/user-attachments/assets/4f0bbea4-31bc-4c48-b5f6-9dc50cd5ae7e)

## Getting started:

### Here I'm using docker and docker compose to setup our database

Make sure both are install are installed on your computer

Now download docker-compose.yaml file and northwind sql file in a folder and open termial in that folder.

Now type below code in the terminal :
> docker-compose up

Now connect to pgAdmin at http://localhost:5050

Now we need to add a new server in pgAdmin:

Hostname: db
Username: postgres
Password: postgres

To stop the server that was launched by docker-compose up via Cntl+C, then remove the containers via:
> docker-compose down



