Select *
FROM Portfolio_project..Covid_deaths
WHERE continent is not null AND population is not null
ORDER BY 3,4

--Select *
--FROM Portfolio_project..CovidVaccinations
--ORDER BY 3,4

-- Select data that we are going to use
Select Location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_project..Covid_deaths
ORDER BY 1,2

-- Total Cases VS Total Deaths
-- Shows the likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Portfolio_project..Covid_deaths
WHERE location like '%india%'
ORDER BY 1,2

-- Looking at total cases VS Population
-- Shows what percentage of peple got Covid

Select Location, date, total_cases,population, (total_cases/population)*100 as AffectedPercentage
FROM Portfolio_project..Covid_deaths
WHERE location like '%india%'
ORDER BY 1,2

-- Looking at countries with Highest Infection Rate compared to papoulation

Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM Portfolio_project..Covid_deaths
-- WHERE location like '%india%'
GROUP by location, population
ORDER BY PercentPopulationInfected desc


-- Showing the countries with highest death count per population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM Portfolio_project .. Covid_deaths
-- WHERE location like '%india%'
WHERE continent is not null AND population is not null
GROUP by location
ORDER BY TotalDeathCount desc


-- BREAKING IT DOWN BY CONTINENT

-- Showing the continents with highest eath count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM Portfolio_project .. Covid_deaths
-- WHERE location like '%india%'
WHERE continent is not null 
GROUP by continent
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS

Select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM Portfolio_project..Covid_deaths
-- WHERE location like '%india%'
where continent is not null 
-- GROUP BY date
ORDER BY 1,2



-- Total Population VS Vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location,
  dea.date) as RollingPeopleVaccination
FROM Portfolio_project .. Covid_deaths dea
JOIN Portfolio_project .. CovidVaccinations vac
    ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null and dea.population is not null
ORDER by 2,3

-- USE CTE

WITH PopvsVac (continent, location, date, population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location,
  dea.date) as RollingPeopleVaccination
FROM Portfolio_project .. Covid_deaths dea
JOIN Portfolio_project .. CovidVaccinations vac
    ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null and dea.population is not null
-- ORDER by 2,3
)
SELECT * , (RollingPeopleVaccinated/population)*100
FROM PopvsVac




-- TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location,
  dea.date) as RollingPeopleVaccination
FROM Portfolio_project .. Covid_deaths dea
JOIN Portfolio_project .. CovidVaccinations vac
    ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null and dea.population is not null
-- ORDER by 2,3
SELECT * , (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


-- Creating view to store data for later visualisations


-- DROP VIEW if exists PercentPopulationVaccinated;
Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location ORDER BY dea.location,
  dea.date) as RollingPeopleVaccination
FROM Portfolio_project .. Covid_deaths dea
JOIN Portfolio_project .. CovidVaccinations vac
    ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null and dea.population is not null
-- ORDER by 2,3


Select *
FROM PercentPopulationVaccinated