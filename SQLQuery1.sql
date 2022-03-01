select *
from PortfolioProject..CovidDeaths
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--looking at Total cases vs Total Deaths in 

SELECT location, date,total_cases,total_deaths, CAST(total_deaths AS decimal)/cast(total_cases as decimal)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%south_africa%'
order by 1,2

--percentage of population got Covid

SELECT location, date,total_cases,population, CAST(total_cases AS decimal)/cast(population as decimal)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%south_africa%'
order by 1,2

--countries with highest infection rate compared to population

SELECT location, population,max(total_cases) as HighestInfectionCount ,max(CAST(total_cases AS decimal)/cast(population as decimal))*100 as 
PercentagePopulationInfected
from PortfolioProject..CovidDeaths
--where location like '%south_africa%'
group by location, population
order by PercentagePopulationInfected desc


--countries with highest death count per population

SELECT location, max(cast(total_deaths as decimal)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%south_africa%'
where continent is not null
group by location
order by TotalDeathCount desc

--continent break down

SELECT location, max(cast(total_deaths as decimal)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%south_africa%'
where continent is null
group by location
order by TotalDeathCount desc

--global numbers

SELECT date,total_cases,total_deaths, CAST(total_deaths AS decimal)/cast(total_cases as decimal)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%south_africa%'
where continent is not null
group by date
order by 1,2


select sum(cast(new_cases as decimal)) as total_cases, sum(cast(new_deaths as decimal)) as total_deaths, sum(cast
(new_deaths as decimal))/sum(cast(new_cases as decimal))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(decimal,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
order by 2,3


--use CTE

with PopvsVac (Continent, location, Date, Population, New_Vaccinations, RollingPeopleVaccined)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(decimal,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *
from PopvsVac

-- temp table

drop Table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(decimal,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select*, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated


-- creating view to store to store for visualization

create View PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,sum(convert(decimal,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3