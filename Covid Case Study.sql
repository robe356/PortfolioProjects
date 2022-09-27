--Select *
--From [Portfolio Project]..[covid deaths]
--order by 3,4



----Select Data that we are going to be using

----select location, date, total_cases, new_cases, total_deaths, population
----from [Portfolio Project]..[covid deaths]
----order by 1,2


---- Total Deaths vs total cases
--select location, date, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
--from [Portfolio Project]..[covid deaths]
--where location like '%states%'
--order by 1,2

---- Total Cases VS Population
--select location, date, total_cases, population, (total_cases/population)*100 as Total 
--from [Portfolio Project]..[covid deaths]
--where location like '%states%'
--order by 1,2

--Countries with the Highest Infection Rates
select location, population, Max(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentPopulationInfected
from [Portfolio Project]..[covid deaths]
--where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc

--Countries with the Highest death count per population
select location,max(cast(total_deaths as int)) as TotalDeathcount
from [Portfolio Project]..[covid deaths]
where continent is not null
Group by location
order by TotalDeathcount desc


-- Continent Beak Down

select location,max(cast(total_deaths as int)) as TotalDeathcount
from [Portfolio Project]..[covid deaths]
where continent is null
Group by location
order by TotalDeathcount desc


-- Looking at total population vs vax

select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations 
, sum(convert(int, vax.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date) as RollingVacCount, 
from [Portfolio Project]..[covid deaths] dea
join [Portfolio Project].. ['covid-vax$'] vax
	on dea.date = vax.date
	and dea.location = vax.location
where dea.continent is not null
order by 2,3


---CTE Example---
with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingVacCount)
as
(
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations 
, sum(convert(int, vax.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date) as RollingVacCount

From [Portfolio Project]..[covid deaths] dea
join [Portfolio Project].. ['covid-vax$'] vax
	on dea.date = vax.date
	and dea.location = vax.location
where dea.continent is not null
--order by 2,3
)
select*, (RollingVacCount/population)*100 as Vaccinated_Population
From PopvsVac


---Create View Storage
Create View PercentpopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations 
, sum(convert(int, vax.new_vaccinations)) Over (partition by dea.location order by dea.location, dea.date) as RollingVacCount
from [Portfolio Project]..[covid deaths] dea
join [Portfolio Project].. ['covid-vax$'] vax
	on dea.date = vax.date
	and dea.location = vax.location
where dea.continent is not null
--order by 2,3
