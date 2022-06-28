select *
from [Covid]..CovidDeaths
where continent is not null
order by 3,4

--select *
--from [Covid]..CovidVaccinations
--order by 3,4

--Select data that we are goint to be using

select location,date,total_cases,new_cases,total_deaths,population
from [Covid]..CovidDeaths
where continent is not null
order by 1,2

--looking at total cases vs total deaths
--likelihood dying
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from [Covid]..CovidDeaths
where location like '%state%'
order by 1,2

--looking at total cases vs population

select location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
from [Covid]..CovidDeaths
--where location like '%state%'
where continent is not null
order by 1,2

--looking at countries with heighest infection vs population

select location,population,max(total_cases) as HeighestInfectionCount,max((total_cases/population))*100 as PercentPopulationInfected
from [Covid]..CovidDeaths
--where location like '%state%'
where continent is not null
group by population,location

order by PercentPopulationInfected desc

--showing countries with heighest death count per population

select location,max(cast(total_deaths as int)) as HeighestDeathCount
from [Covid]..CovidDeaths
--where location like '%state%'
where continent is not null
group by location
order by HeighestDeathCount desc

--let's break thing down by continent

select continent,max(cast(total_deaths as int)) as HeighestDeathCount
from [Covid]..CovidDeaths
--where location like '%state%'
where continent is not null
group by continent
order by HeighestDeathCount desc

--Global numbers
--1
select sum(new_cases) as total_cases,sum(cast(new_deaths as int))as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Covid]..CovidDeaths
--where location like '%state%'
where continent is not null
--group by date
order by 1,2

--looking at total_population vs vaccination
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int , vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
from [Covid]..CovidDeaths dea
join [Covid]..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--use cte

with PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated) as(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int , vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
from [Covid]..CovidDeaths dea
join [Covid]..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
)
select *,(RollingPeopleVaccinated/population)*100
from PopvsVac

--TEMPT Table
drop table if exists PercentPopulationVaccinated
create table PercentPopulationVaccinated

(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
RollingPeopleVaccinated numeric
)
insert into PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int , vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
from [Covid]..CovidDeaths dea
join [Covid]..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100
from PercentPopulationVaccinated


--creating view to store data for later visualization

create view PercentPopulationVaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(convert(int , vac.new_vaccinations)) over (partition by dea.location order by dea.location , dea.date) as RollingPeopleVaccinated
from [Covid]..CovidDeaths dea
join [Covid]..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
--1
select sum(new_cases) as total_cases,sum(cast(new_deaths as int))as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [Covid]..CovidDeaths
--where location like '%state%'
where continent is not null
--group by date
order by 1,2

--2
select location,sum(cast(total_deaths as int)) as TotalDeathsCount
from [Covid]..CovidDeaths
where continent is null
and location not in ('world','Eropian Union','International')
group by location
order by TotalDeathsCount desc

--3
select location,population,max(total_cases) as HeighestInfectionCount,max(total_cases/population)*100 as PercentPopulationInfected
from [Covid]..CovidDeaths
group by location,population
order by PercentPopulationInfected desc

--4
SELECT location,population,date,max(total_cases) as HeighestInfectedCount,
max(total_cases/population)*100 PercentPopulationInfected
from [Covid]..CovidDeaths
group by location,population,date
order by PercentPopulationInfected desc