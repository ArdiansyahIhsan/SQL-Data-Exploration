--Coviddeath Data Explorer

Select 
	*
From 
	Coviddeaths
WHERE 
	Continent IS NOT NULL
Order By 3,4


-- Select data that we are going to be using

Select 
	location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
From 
	Coviddeaths
WHERE 
	Continent IS NOT NULL
Order By 1,2

-- Looking at Total Cases vs Total Deaths 

Select 
	location, 
	date, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 as DeathPrecentage
From 
	Coviddeaths
Where 
	Location = 'Indonesia'
	AND (total_deaths/total_cases)*100 IS NOT NULL
Order By 1,2


-- Looking at Total Cases vs Population
-- Show what precentage of population got covid

Select 
	location, 
	date, 
	population, 
	total_cases, 
	(total_cases/population)*100 as PercentagePopulationInfected
From 
	Coviddeaths
Where
	continent IS NOT NULL
Order By 1,2

-- Looking at Countries with Highest Infection Rate Compared to Population 

SELECT 
	location, 
	population, 
	Max(total_cases) AS HighestInfectionCount,
	Max((total_cases/population))*100 AS PercentagePopulationInfected
FROM 
	Coviddeaths
Where 
	continent IS NOT NULL
GROUP BY 
	location, 
	population
HAVING 
	Max((total_cases/population))*100 IS NOT NULL 
ORDER BY 
	PercentagePopulationInfected DESC

-- Shows Countries with Highest Death Count per Population

SELECT 
	location,  
	Max(total_deaths) AS TotalDeathCount
FROM 
	Coviddeaths
Where 
	continent IS NOT NULL
GROUP BY 
	location
HAVING Max(total_deaths) IS NOT NULL
ORDER BY 
	TotalDeathCount DESC

--Showing continent with the highest death count per population

SELECT 
	continent,  
	Max(total_deaths) AS TotalDeathCount
FROM 
	Coviddeaths
Where 
	continent IS NOT NULL
GROUP BY 
	continent
HAVING Max(total_deaths) IS NOT NULL
ORDER BY 
	TotalDeathCount DESC


-- Global Numbers

SELECT
	SUM(new_cases) as total_cases,
	SUM(new_deaths) as total_deaths,
	SUM(new_deaths) / SUM(new_cases)*100 as DeathPercentage
FROM
	coviddeaths
WHERE
	continent IS NOT NULL
ORDER BY 1,2

--CovidVaccination Data Explorer

Select 
	*
From 
	Covidvaccinations
WHERE 
	Continent IS NOT NULL
Order By 3,4

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select
	d.continent,
	d.location,
	d.date,
	d.population,
	v.new_vaccinations,
	SUM(v.new_vaccinations) OVER (Partition By d.location Order By d.location, d.date) as RollingPeopleVaccinated
From
	Covidvaccinations as v
Join 
	Coviddeaths as d 
ON v.location = d.location AND v.date = d.date
WHERE 
	d.continent is not null
Order By 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select
	d.continent,
	d.location,
	d.date,
	d.population,
	v.new_vaccinations,
	SUM(v.new_vaccinations) OVER (Partition By d.location Order By d.location, d.date) as RollingPeopleVaccinated
From
	Covidvaccinations as v
Join 
	Coviddeaths as d 
ON v.location = d.location AND v.date = d.date
WHERE 
	d.continent is not null
-- Order By 2,3
)
SELECT 
	*,
	(RollingPeopleVaccinated/population)*100 as PercentPopulationVaccinated
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

Create Table PercentPopulationVaccinated
(
continent VARCHAR(50),
location VARCHAR(100),
date DATE,
population FLOAT,
new_vaccinations FLOAT,
RollingPeopleVaccinated FLOAT
);

Insert into PercentPopulationVaccinated
Select
	d.continent,
	d.location,
	d.date,
	d.population,
	v.new_vaccinations,
	SUM(v.new_vaccinations) OVER (Partition By d.location Order By d.location, d.date) as RollingPeopleVaccinated
From
	Covidvaccinations as v
Join 
	Coviddeaths as d 
ON v.location = d.location AND v.date = d.date
-- WHERE 
-- 	d.continent is not null
-- Order By 2,3
;

Select *, (RollingPeopleVaccinated/Population)*100 as PercentVaccinated
From PercentPopulationVaccinated
