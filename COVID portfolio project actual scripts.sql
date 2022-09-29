Select *
from [PortfolioProject].[dbo].[CovidDeaths$]
where continent is not null
order by 3,4

--Select *
--from [PortfolioProject]..CovidVaccinations$
--order by 3,4


-- select data to be used

Select location, date, total_cases, new_cases, total_deaths, population
from [PortfolioProject].[dbo].[CovidDeaths$]
order by 1,2



-- looking at total cases vs total deaths
-- shows the likelihood of dying if you contract Covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [PortfolioProject].[dbo].[CovidDeaths$]
where location like '%nigeria%'
order by 1,2



--looking at total cases vs population
-- shows what percentage of population got covid
Select location, date, population, total_cases, (total_cases/population)*100 as PercentageOfInfectedPopulation
from [PortfolioProject].[dbo].[CovidDeaths$]
-- where location like '%nigeria%'
order by 1,2



-- looking at countries with highest infection rates compared to population
Select location, population, max(total_cases)as MaxInfectionCount, max(total_cases/population)*100 as PercentageOfInfectedPopulation
from [PortfolioProject].[dbo].[CovidDeaths$]
-- where location like '%nigeria%'
group by location, population
order by PercentageOfInfectedPopulation desc


--showing countries with highest death count per population
Select location, max(cast(total_deaths as int))as TotalDeathCount
from [PortfolioProject].[dbo].[CovidDeaths$]
-- where location like '%nigeria%'
where continent is not null
group by location
order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT



--showing continents with highest death cunt per population

Select continent, max(cast(total_deaths as int))as TotalDeathCount
from [PortfolioProject].[dbo].[CovidDeaths$]
-- where location like '%nigeria%'
where continent is not null
group by continent
order by TotalDeathCount desc




--GLOBAL NUMBERS
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int)) /sum(new_cases)*100 as DeathPercentage
from [PortfolioProject].[dbo].[CovidDeaths$]
--where location like '%nigeria%'
where continent is not null
--group by date
order by 1,2


--looking at total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
     sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
     dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null
order by 1,2


--USE CTE
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
     dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac



-- TEMP TABLE
Drop table if exists #PercentPopulationVaccinated 
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
     dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 1,2

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated





--creating view to store data for later visualizations

create view 
#PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
     dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ dea
join PortfolioProject..CovidVaccinations$ vac
    on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2


select*
from PercentPopulationVaccinated

