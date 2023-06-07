# DAta_Analysis
## COVID-19 Data Analysis Project

This project focuses on analyzing COVID-19 data using SQL. The data used in the analysis was sourced from ourworldindata.org. The objective is to gain insights into the COVID-19 pandemic and its impact on different locations and populations.

## SETUP
Start by importing the COVID-19 data into an SQL Server database. The data consists of two tables, Covid_Deaths and Covid_Vaccinations.

## SQL QUERIES
The following SQL queries were used to analyze and explore the COVID-19 data:

### 1. Total Cases and Deaths by Location: The query retrieves data on location, date, total cases, new cases, total deaths, and population from the Covid_Deaths table, sorted by location and date.

select Location, date, total_cases, new_cases, total_deaths, population from COvid_Deaths
order by 1,2;

### 2. Death Percentage: This query calculates the death percentage (total deaths as a percentage of total cases) for each location in the Covid_Deaths table, sorted by location and date.

SELECT Location, date, total_cases, new_cases, total_deaths, (total_deaths * 100/ total_cases) AS DeathPercentage
FROM Covid_Deaths
ORDER BY Location, date;

### 3. Likelihood of Dying from COVID-19 in Kenya: The query specifically focuses on Kenya and calculates the death percentage over time, providing insights into the likelihood of dying from COVID-19 in Kenya.

SELECT Location, date, total_cases, new_cases, total_deaths, (total_deaths * 100/ total_cases) AS DeathPercentage
FROM Covid_Deaths
where location = 'Kenya'
ORDER BY Location, date;

### 4. Cases Percentage in Kenya: This query calculates the percentage of total cases in Kenya compared to the population over time, helping understand the impact of COVID-19 on the population.

SELECT Location, date, total_cases, new_cases, population, (total_cases * 100/ population) AS CasesPercentage
FROM Covid_Deaths
where location = 'Kenya'
ORDER BY Location, date;

### 5. Highest Infection Rates by Population: The query identifies countries with the highest infection rates (total cases as a percentage of the population) and sorts them by the highest infection count. It provides insights into the impact of COVID-19 relative to the population.

SELECT
    Location,
    MAX(CAST(total_cases AS bigint)) as HighestInfection,
    new_cases,
    population,
    MAX(CAST(total_cases AS bigint) * 100.0 / CAST(population AS bigint)) AS InfectionPercentage
FROM
    Covid_Deaths
GROUP BY
    Location,
    new_cases,
    population
ORDER BY
    Location,
    HighestInfection DESC;
    

### 6. Highest Death Count by Location: This query retrieves the location and highest death count for each location in the Covid_Deaths table, sorted by the total death count.

select Location, MAX(Total_deaths) as TotalDeathCount
from COvid_Deaths
Group by location
order by TotalDeathCount desc;

### 7. Total Deaths by Location (Excluding Continent): The query shows the total death count for each location, excluding the continent. The results are sorted by the total death count.

select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from COvid_Deaths
where continent is null
Group by location
order by TotalDeathCount desc;

### 8. Total Number of Cases Recorded Globally: This query calculates the total number of cases, total deaths, and the death percentage globally using data from the Covid_Deaths table.

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int)) /SUM(New_Cases)*100 as DeathPercentage
from COvid_Deaths;

### 9. Total Population vs. Vaccinations: This query retrieves data on the continent, location, date, population, and new vaccinations from the Covid_Deaths and Covid_Vaccinations tables. It provides insights into the relationship between population and vaccination efforts.

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from COvid_Deaths dea
join COvid_Vaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1, 2, 3;

### 10. CTE: Rolling People Vaccinated: This query utilizes a Common Table Expression (CTE) to calculate the rolling count of people vaccinated over time for each location in the Covid_Deaths and Covid_Vaccinations tables.

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
    SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.Location ORDER BY dea.Date) AS RollingPeopleVaccinated
    FROM
        Covid_Deaths dea
    JOIN
        Covid_Vaccinations vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE
        dea.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac;

### 11. Temporary Table: PercentagePopulationVaccinated: This query creates a temporary table to store data related to the percentage of population vaccinated. It combines data from the Covid_Deaths and Covid_Vaccinations tables.

Create Table PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into PercentagePopulationVaccinated

SELECT
        dea.continent,
        dea.location,
        dea.date,
        dea.population,
        vac.new_vaccinations,
        SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.Location ORDER BY dea.Date) AS RollingPeopleVaccinated
    FROM
        Covid_Deaths dea
    JOIN
        Covid_Vaccinations vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE
        dea.continent IS NOT NULL;

    SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PercentagePopulationVaccinated;


### 12. Creating a View: PercentagePopulationVaccinated: This query creates a view named PercentagePopulationVaccinated that provides a consolidated view of the percentage of population vaccinated. It utilizes data from the Covid_Deaths and Covid_Vaccinations tables.

CREATE VIEW PercentagePopulationVaccinated AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
FROM
    Covid_Deaths dea
JOIN
    Covid_Vaccinations vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;
    
 ## Additional Notes
 
 Ensure that the table names (Covid_Deaths and Covid_Vaccinations) in the queries match the actual table names in your SQL Server database.
 
 
 #### Feel free to modify the queries or add more analyses based on your requirements. Have fun exploring and analyzing the COVID-19 data!


