SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not NULL
ORDER BY 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in you country

SELECT location, date, total_cases, total_deaths, 
(CONVERT(float,total_deaths) / NULLIF(CONVERT(float,total_cases),0))*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%' AND continent is NOT NULL
ORDER BY 1,2


-- Looking at Total Cases vs Population

SELECT location, date, population, total_cases,
(cast(total_cases as INT) / cast(population AS INT))*100 AS PercentOfPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not NULL
ORDER BY 1,2


-- Looking at Countries with the highest infection rate compared to population

SELECT location,
	   population, 
	   MAX(total_cases) as HighestInfectionCount,
	   MAX((cast(total_cases as INT) / cast(population AS INT)))*100 AS PercentOfPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not NULL
GROUP BY location, population 
ORDER BY PercentOfPopulationInfected desc


-- Showing the Countries with the Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not NULL
GROUP BY location 
ORDER BY TotalDeathCount desc



-- Showing continents with Highest Death Count

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is NOT NULL  
GROUP BY continent 
ORDER BY TotalDeathCount desc 



-- GLOBAL NUMBERS

SELECT date, 
	SUM(new_cases) AS TotalCases, 
	SUM(new_deaths) AS TotalDeaths, 
	SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
GROUP BY date
ORDER BY 1,2


SELECT 
	SUM(new_cases) AS TotalCases, 
	SUM(new_deaths) AS TotalDeaths, 
	SUM(new_deaths)/NULLIF(SUM(new_cases),0)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 1,2



-- Looking at Total Popualtion vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(new_vaccinations as BIGINT)) over (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccination
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3


-- USE CTE

WITH PopVsVac (continent, location, date, population, new_vaccinations, RollingVaccination)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(new_vaccinations as BIGINT)) over (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccination
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
)
SELECT *, (RollingVaccination/population)*100
FROM PopVsVac


-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingVaccination numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(new_vaccinations as BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccination
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is NOT NULL

SELECT *, (RollingVaccination/population)*100
FROM #PercentPopulationVaccinated





--Creating a view to store the data for visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(new_vaccinations as BIGINT)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingVaccination
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL



SELECT *
FROM PercentPopulationVaccinated