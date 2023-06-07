use PortfolioProject;
-- viewing COvid_Deaths Table
select * 
from COvid_Deaths;

--viewing COvid_Vaccinations Table
select *
from COvid_Vaccinations;

--Selecting the data that I will be using

select Location, date, total_cases, new_cases, total_deaths, population from COvid_Deaths
order by 1,2;


--looking at Total Cases vs Total Deaths
SELECT Location, date, total_cases, new_cases, total_deaths, (total_deaths * 100/ total_cases) AS DeathPercentage
FROM Covid_Deaths
ORDER BY Location, date;

--Showing the likelihood of dying if you contract covid in Kenya
SELECT Location, date, total_cases, new_cases, total_deaths, (total_deaths * 100/ total_cases) AS DeathPercentage
FROM Covid_Deaths
where location = 'Kenya'
ORDER BY Location, date;

--Looking at the total cases vs total population in Kenya
SELECT Location, date, total_cases, new_cases, population, (total_cases * 100/ population) AS CasesPercentage
FROM Covid_Deaths
where location = 'Kenya'
ORDER BY Location, date;

--Looking at countries with Highest Infection RAte compared to the population
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


--showing countries with Highest Death Count per Population
select Location, MAX(Total_deaths) as TotalDeathCount
from COvid_Deaths
Group by location
order by TotalDeathCount desc;

--Showing  numbers by continent
select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from COvid_Deaths
where continent is null
Group by location
order by TotalDeathCount desc;

--Total Number of cases recorded globally
select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int)) /SUM(New_Cases)*100 as DeathPercentage
from COvid_Deaths;

--looking at total population vs vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from COvid_Deaths dea
join COvid_Vaccinations vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1, 2, 3;

--USE CTE
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



--TEMP TABLE
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


--Creating View to store data for visualization

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


--Dropping existing view object
DROP VIEW PercentagePopulationVaccinated;


CREATE VIEW NewViewName AS
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


