
SELECT
	location, date, total_cases, new_cases, total_deaths, population
FROM 
	PortfolioProject..CovidDeaths
WHERE
	continent is not null     /* If continent is Null, there are name of continents in 'location' column */
ORDER BY 3, 4;


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country (on 2021-04-30)

SELECT 
	location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 DeathPercentage
FROM 
	PortfolioProject..CovidDeaths
WHERE
	location like 'Russia%'  
	and continent is not null
ORDER BY 1, 2;


-- Looking at Total Cases vs Population 
-- Shows what percentage of population got covid

SELECT
	location, date, total_cases, population, round((total_cases/population) * 100, 3) Percentage
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent is not null
ORDER BY 1, 2;


-- Looking at Countries with Highest Infection Rate compared to Population

SELECT
	location,
	population,
	MAX(total_cases) HighestInfectionCount,
	MAX(total_cases/population) * 100 PercentPopulationInfected
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent is not null
GROUP BY
	location, population
ORDER BY
	PercentPopulationInfected desc;


-- Showing Countries with Highest Death Count per Population

SELECT
	location,
	MAX(cast(total_deaths as int)) TotalDeathCount 
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent is not null
GROUP BY 
	location
ORDER BY
	TotalDeathCount desc;


-- -- Showing continents with the highest death count per population

SELECT
	location, 
	MAX(cast(total_deaths as int)) TotalDeathCount 
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent is null
GROUP BY
	location
ORDER BY	
	TotalDeathCount desc;

SELECT
	continent,
	MAX(cast(total_deaths as int)) TotalDeathCount 
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent is null
GROUP BY
	location
ORDER BY	
	TotalDeathCount desc;


-- GLOBAL NUMBERS

SELECT 
	date,
	SUM(new_cases) total_cases,
	SUM(cast(new_deaths as int)) total_deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases) * 100 DeathPercentage
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent is not null
GROUP BY
	date
order by
	1, 2;

SELECT 
	SUM(new_cases) total_cases,
	SUM(cast(new_deaths as int)) total_deaths,
	SUM(cast(new_deaths as int))/SUM(new_cases) * 100 DeathPercentage
FROM
	PortfolioProject..CovidDeaths
WHERE
	continent is not null
order by 1, 2;


-- Looking at Total Population vs Vaccinations

SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) 
		OVER (Partition by dea.location ORDER BY dea.location, dea.date)
		AS RollingPeopleVaccinated
FROM
	PortfolioProject..CovidDeaths dea
	JOIN
	PortfolioProject..CovidVaccinations vac
	ON 
	dea.location = vac.location 
	AND
	dea.date = vac.date
WHERE 
	dea.continent is not null
ORDER BY 2, 3;


-- USE CTE

WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS (
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) 
		OVER (Partition by dea.location ORDER BY dea.location, dea.date)
		AS RollingPeopleVaccinated
FROM
	PortfolioProject..CovidDeaths dea
	JOIN
	PortfolioProject..CovidVaccinations vac
	ON 
	dea.location = vac.location 
	AND
	dea.date = vac.date
WHERE 
	dea.continent is not null
)

SELECT *, (RollingPeopleVaccinated/population) * 100 PersentPopulationVaccinated
FROM PopVsVac



-- TEMP TABLE

DROP TABLE IF EXISTS #PersentPopulationVaccinated
CREATE TABLE #PersentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PersentPopulationVaccinated
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) 
		OVER (Partition by dea.location ORDER BY dea.location, dea.date)
		AS RollingPeopleVaccinated
FROM
	PortfolioProject..CovidDeaths dea
	JOIN
	PortfolioProject..CovidVaccinations vac
	ON 
	dea.location = vac.location 
	AND
	dea.date = vac.date

SELECT *, (RollingPeopleVaccinated/population) * 100 PersentPopulationVaccinated
FROM #PersentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PersentPopulationVaccinated AS
SELECT
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations,
	SUM(CONVERT(int, vac.new_vaccinations)) 
		OVER (Partition by dea.location ORDER BY dea.location, dea.date)
		AS RollingPeopleVaccinated
FROM
	PortfolioProject..CovidDeaths dea
	JOIN
	PortfolioProject..CovidVaccinations vac
	ON 
	dea.location = vac.location 
	AND
	dea.date = vac.date
WHERE 
	dea.continent is not null


SELECT * 
FROM PersentPopulationVaccinated