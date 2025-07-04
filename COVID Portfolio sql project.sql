select *
From [portfolio project]..CovidDeaths
where continent is not null
order by 3,4

--select *
--From [portfolio project]..CovidVaccinations
--order by 3,4

select location,date,total_cases,new_cases,total_deaths,population
From [portfolio project]..CovidDeaths
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying if you contract covid in your country
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From [portfolio project]..CovidDeaths
and continent is not null
where location like '%states%'
order by 1,2

--looking at total cases vs population
--shows percentage of population got covid
select location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
From [portfolio project]..CovidDeaths
order by 1,2

--looking at countries where highets infection rate compared to population
select location,population,MAX(total_cases) as highestinfectioncount,MAX((total_cases/population))*100 as PercentPopulationInfected
From [portfolio project]..CovidDeaths
Group by location,population
order by  PercentPopulationInfected desc

--LETS BREAK THINGS DOWN BY CONTINENT --showing continents with highest death count per population
select location,	MAX(cast(total_deaths as int)) as TotalDeathCount
From [portfolio project]..CovidDeaths
where continent is  null
Group by location
order by   TotalDeathCount desc

--global numbers
select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(New_deaths as int))/SUM(New_cases)*100 as DeathPercentage--,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From [portfolio project]..CovidDeaths
where continent is not null
--where location like '%states%'

--group by date
order by 1,2


--lookong at total population vs vaccinations
--USE CTE
-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [portfolio project]..CovidDeaths dea
Join [portfolio project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac




--TEMP TABLE

-- Step 1: Create temp table
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [portfolio project]..CovidDeaths dea
Join [portfolio project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [portfolio project]..CovidDeaths dea
Join [portfolio project]..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 



