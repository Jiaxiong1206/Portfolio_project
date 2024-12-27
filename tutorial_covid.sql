SELECT *
fROM Portfolio_Project ..CovidDeaths
where continent is not null 
order by 3,4

--SELECT *
--fROM Portfolio_Project ..CovidVaccinations
--order by 3,4

-- Select data to analyse
Select location, date, total_cases, new_cases, total_deaths, population 
From Portfolio_Project ..CovidDeaths
order by 1,2

-- Total cases vs total deaths in Malaysia
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From Portfolio_Project ..CovidDeaths
where location like 'Malay%'
order by 1,2

-- Total cases vs population 
Select location, date, total_cases, population, (total_cases/population)*100 as Covid_Victim_Percentage
From Portfolio_Project ..CovidDeaths
where location like 'Malay%'
order by 1,2

-- Countries with highest infection rate vs Population
Select location, max(total_cases) as Highest_infection_Count, population, max(total_cases/population)*100 as Max_Covid_Victim_Percentage
From Portfolio_Project ..CovidDeaths
Group by Location, population
order by Max_Covid_Victim_Percentage desc

-- Countries with highest death count per population 
Select location, max(cast(total_deaths as int)) as total_deathcount
From Portfolio_Project ..CovidDeaths
where continent is not null 
group by Location
order by total_deathcount desc

-- covid cases among the continents 
Select location, max(cast(total_cases as int)) as highest_cases
From Portfolio_Project ..CovidDeaths
where continent is null 
group by location
order by highest_cases desc

-- Highest death counts
Select location, max(cast(total_deaths as int)) as total_deathcount
From Portfolio_Project ..CovidDeaths
where continent is null 
group by location
order by total_deathcount desc

-- Global numbers
Select sum(cast(new_cases as int)) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int)) /sum(new_cases)*100 as DeathPercentage
From Portfolio_Project ..CovidDeaths
where continent is null 
order by 1,2

-- total population vs total vaccinations with CTE

With PopVsVac (Continent, Location, Date, Population, new_vaccinations, rollingvaccinated_per_day)
As
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) Over (Partition by dea.location order by dea.location, dea.date) as rollingvaccinated_per_day
From Portfolio_Project .. CovidDeaths dea
join Portfolio_Project .. CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3 // cant use in CTE
)
Select *, (rollingvaccinated_per_day)/population *100 as rollingvaccinated_percentage
From PopVsVac


-- Temp table
-- First, drop the temporary table if it exists
--Drop table if exists #Vaccinatedpopulationpercentage
--Create Table #Vaccinatedpopulationpercentage
--(
--continent nvarchar(255),
--location nvarchar(255),
--date datetime,
--population numeric,
--new_vaccinations numeric,
--rollingvaccinated_per_day numeric
--)
--Insert into #Vaccinatedpopulationpercentage
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, sum(convert(int,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as rollingvaccinated_per_day
--From Portfolio_Project .. CovidDeaths dea
--join Portfolio_Project .. CovidVaccinations vac
--    On dea.location = vac.location
--    and dea.date = vac.date

--Select *, (rollingvaccinated_per_day)/population *100 as rollingvaccinated_percentage
--From #Vaccinatedpopulationpercentage

-- Creating view to store data for visualization
Create view percentpopularvaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int,vac.new_vaccinations)) Over (Partition by dea.location order by dea.location, dea.date) as rollingvaccinated_per_day
From Portfolio_Project .. CovidDeaths dea
join Portfolio_Project .. CovidVaccinations vac
    On dea.location = vac.location
    and dea.date = vac.date
where dea.continent is not null 


select *
from percentpopulationvaccinated