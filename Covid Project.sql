-- SELECT DATA THAT WE ARE GOING TO BE USING 

SELECT [location], [date],[total_cases],[new_cases_per_million],[total_deaths_per_million],[population]
FROM [dbo].[CovidDeathsok]
ORDER BY 1,2


--Looking at Total case vs Total Deaths 

SELECT [location], [date],[total_cases],[total_deaths_per_million], (total_deaths_per_million/ total_cases_per_million)*100 AS DeathPercentage 
FROM [dbo].[CovidDeathsok]
ORDER BY 1,2

-- Show likelihood of dying if you contract Covid in your conuntry 

SELECT [location], [date],[total_cases],[total_deaths_per_million], (total_deaths_per_million/ total_cases_per_million)*100 AS DeathPercentage 
FROM [dbo].[CovidDeathsok]
WHERE [location] like '%states%'
ORDER BY 1,2

-- Looking at Total cases vs Population 
--Show what percentage of popultion got Covid

SELECT [location], [date],[population],[total_cases], (total_cases/population)*100 AS PercentPopulationInfected
FROM [dbo].[CovidDeathsok]
WHERE [location] like '%states%'
ORDER BY 1,2

--Looking at conuntries with highest infection rate compared to Population 
SELECT [location],[population],Max([total_cases]) AS HighestInfectionCountr, Max((total_cases/population))*100 AS PercentPopulationInfected 
FROM [dbo].[CovidDeathsok]
--WHERE [location] like '%states%'\
GROUP BY [location], population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries wit Higesht Death Count per Population

SELECT [location],Max (total_deaths) AS TotalDeathCountr 
FROM [dbo].[CovidDeathsok]
--WHERE [location] like '%states%'\
WHERE continent is not NULL
GROUP BY [location]
ORDER BY TotalDeathCountr DESC


--Let's brak things down by continent

SELECT continent,Max (total_deaths) AS TotalDeathContinent
FROM [dbo].[CovidDeathsok]
--WHERE [location] like '%states%'\
WHERE continent is not NULL
GROUP BY [continent]
ORDER BY TotalDeathContinent DESC


SELECT [location],Max (total_deaths) AS TotalDeathContinent
FROM [dbo].[CovidDeathsok]
--WHERE [location] like '%states%'\
WHERE continent is NULL
GROUP BY [location]
ORDER BY TotalDeathContinent DESC


-- Global Numbers

SELECT [date], SUM([new_cases]) AS Total_case, SUM(new_deaths)AS Total_Deaths, SUM(new_deaths)/ SUM(new_cases)*100 AS DeathPercentage
FROM [dbo].[CovidDeathsok]
WHERE [continent] IS not NULL
GROUP BY [date]
ORDER BY 1, 2


-- Looking at Total Population vrs Vaccintions 

SELECT  DEA.continent, DEA.[location], DEA.[date], DEA.population, VAC.new_vaccinations, 
SUM(VAC.new_vaccinations) OVER (PARTITION BY DEA. [location] 
ORDER BY DEA. [location], DEA.[date] ) AS RollingPeopleVaccinated
FROM Proyect..CovidDeathsok DEA
JOIN Proyect..[Copia de CovidVaccinations] VAC
    ON DEA. [location]= VAC.[location]
    and DEA.[date]=VAC.[date]
WHERE DEA.continent IS NOT NULL
ORDER BY  2, 3

--USE CTE

WITH PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT  DEA.continent, DEA.[location], DEA.[date], DEA.population, VAC.new_vaccinations, 
SUM(VAC.new_vaccinations) OVER (PARTITION BY DEA. [location] 
ORDER BY DEA. [location], DEA.[date] ) AS RollingPeopleVaccinated
FROM Proyect..CovidDeathsok DEA
JOIN Proyect..[Copia de CovidVaccinations] VAC
    ON DEA. [location]= VAC.[location]
    and DEA.[date]=VAC.[date]
WHERE DEA.continent IS NOT NULL
--ORDER BY  2, 3
)

SELECT*, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


-- Creating view to store data fot later visualiztions
CREATE VIEW PercentPopulationVaccinated
AS
SELECT DEA.continent, DEA.[location], DEA.[date], DEA.population, VAC.new_vaccinations, 
SUM(VAC.new_vaccinations) OVER (PARTITION BY DEA. [location] 
ORDER BY DEA. [location], DEA.[date] ) AS RollingPeopleVaccinated
FROM Proyect..CovidDeathsok DEA
JOIN Proyect..[Copia de CovidVaccinations] VAC
    ON DEA. [location]= VAC.[location]
    and DEA.[date]=VAC.[date]
WHERE DEA.continent IS NOT NULL
--ORDER BY  2, 3
