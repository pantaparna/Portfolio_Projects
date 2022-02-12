*/ Data Exploration
Skills used : CTE'S, Temp table, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From coviddeaths
Where continent is not null 
order by 3,4

-- Select Data that we are going to be starting with

Select Location, date, totalCases, newCases, totalDeaths, population
From coviddeaths
Where continent is not null 
order by 1,2

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in the United States

Select Location, date, totalCases,totalDeaths, (totalDeaths/totalCases)*100 as DeathPercentage
From coviddeaths
Where location like '%states%'
and continent is not null 
order by 1,2

-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, totalCases,  (totalCases/population)*100 as PercentPopulationInfected
From coviddeaths
-- Where location like '%states%'
order by 1,2

-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(totalCases) as HighestInfectionCount,  Max((totalCases/population))*100 as PercentPopulationInfected
From coviddeaths
-- Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc

-- Countries with Highest Death Count per Population

Select Location, MAX(totalDeaths) as TotalDeathCount
From coviddeaths
-- Where location like '%states%'
Where continent is not null 
Group by Location
order by TotalDeathCount desc

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(totalDeaths as int) as TotalDeathCount
From coviddeaths
-- Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select date, SUM(newCases) as totalCases, SUM(newDeaths) as total_deaths, SUM(newDeaths)/SUM(newCases)*100 as DeathPercentage
From coviddeaths
-- Where location like '%states%'
where continent is not null 
Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From PortFolio_Project.coviddeaths dea
Join PortFolio_Project.covidvaccination vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
order by 1,2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From PortFolio_Project.coviddeaths dea
Join PortFolio_Project.covidvaccination vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
order by 1,2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From PortFolio_Project.coviddeaths dea
Join PortFolio_Project.covidvaccination vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null 
order by 1,2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
From PortFolio_Project.coviddeaths dea
Join PortFolio_Project.covidvaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
