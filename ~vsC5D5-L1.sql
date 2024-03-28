--select * from CovidVaccination
--order by 3,4

select * from CovidDeaths
where continent is not null
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

-- looking at total cases vs total deaths
--% that died that had covid

select location, date, total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercent
from CovidDeaths
where location like '%kingdom%'
order by 1,2

--looking at the total_cases vs population
--showing what percentage of population got covid

select location, date, population, total_cases, (cast(total_cases as float)/cast(population  as float))*100 as percentagePopulationInfected
from CovidDeaths
where location like '%kingdom%'
order by 1,2

--looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as HighestInfectionCount, max((cast(total_cases as float)/cast(population  as float)))*100 as percentagePopulationInfected
from CovidDeaths
--where location like '%kingdom%'
where continent is not null
group by location, population
order by percentagePopulationInfected desc

-- showing the countries with the highest death count per population

select location, max(cast(total_deaths as int)) as TotalDeathCount 
from CovidDeaths
--where location like '%kingdom%'
where continent is not null
group by location
order by TotalDeathCount desc

-- showing by continent with the highest death count per population

select continent, max(cast(total_deaths as int)) as TotalDeathCount 
from CovidDeaths
--where location like '%kingdom%'
where continent is not null
group by continent
order by TotalDeathCount desc

  --showing globally

select sum(new_cases) as total_cases, sum(new_deaths) as total_death, sum(new_deaths)/sum(new_cases)*100 as DeathPercent
from CovidDeaths
--where location like '%kingdom%'
where continent is not null
--group by date
order by 1,2

-- looking at total population vs vaccination
 
select *    
from CovidDeaths dea
join CovidVaccination vac
on dea.location =vac.location and dea.date = vac.date

--summing vaccination by location
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) over(partition by dea.location)
from CovidDeaths dea
join CovidVaccination vac
on dea.location =vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date rows unbounded preceding) as RollingpeopleVaccinated
from CovidDeaths dea
join CovidVaccination vac
on dea.location =vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3

--CTE(Common table Expression)

with PopvsVac (continent, location, date,population, new_vaccinations, RollingpeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location, 
dea.date rows unbounded preceding) as RollingpeopleVaccinated
from CovidDeaths dea
join CovidVaccination vac
	on dea.location =vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingpeopleVaccinated/population)*100
from PopvsVac

--Temp table
drop table if exists #PercentPopulationVaccinated
create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
New_Vaccination numeric,
RollingpeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location, 
dea.date rows unbounded preceding) as RollingpeopleVaccinated
from CovidDeaths dea
join CovidVaccination vac
	on dea.location =vac.location 
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingpeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--creating view to store date for later visualization 

create view PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over(partition by dea.location order by dea.location, 
dea.date rows unbounded preceding) as RollingpeopleVaccinated
from CovidDeaths dea
join CovidVaccination vac
	on dea.location =vac.location 
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3 

select *
from PercentPopulationVaccinated