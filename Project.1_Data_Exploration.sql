
select *
from CovidDeaths

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 3,4

-- Total cases VS Total Deaths (Percentage of Deaths)
select location, date, total_cases, new_cases, new_deaths, total_deaths, (cast(total_deaths as float)/CAST(total_cases as float))*100 as DeathPercentage
from CovidDeaths
where location like 'india'
order by 1,2

-- Total cases VS Population (Percentage of Covid_Cases)
select location, date, total_cases, new_cases, population, (cast(total_cases as float)/CAST(population as float))*100 as CovidCasesPercentage
from CovidDeaths
where location like '%states%'
order by 1,2

-- Looking at Countries with highest infected rate compared to population

select location, population, max(cast(total_cases as int)) as Infected_PPL, max(cast(total_cases as float)/CAST(population as float))*100 as CovidCasesPercentage
from CovidDeaths
--where location like '%states%'
group by location, population
order by CovidCasesPercentage desc

-- Looking at Countries with highest Death rate compared to population

select location, population, max(cast(total_deaths as int)) as Deaths, max(cast(total_deaths as float)/CAST(population as float))*100 as CovidDeathPercentage
from CovidDeaths
--where location like '%india%'
where continent is null
group by location, population
order by CovidDeathPercentage desc

select continent, max(cast(total_deaths as int)) as Deaths, max(cast(total_deaths as float)/CAST(population as float))*100 as CovidDeathPercentage
from CovidDeaths
--where location like '%india%'
where continent is not null
group by continent
order by CovidDeathPercentage desc


-- Global numbers

select location, date, max(cast(total_cases as int)) as cases, sum(cast(new_cases as int)) as newcases--, total_deaths
from CovidDeaths
where continent is not null
group by location, date
order by cases desc

-- Total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
	over (partition by dea.location order by dea.date) as tot_vac
from CovidDeaths as dea join CovidVaccinations as vac
on dea.date = vac.date and dea.location = vac.location
where dea.continent is not null
order by 2,3

select dea.continent, dea.location, max(cast(vac.total_vaccinations as bigint)) as tot_vac
from CovidDeaths as dea join CovidVaccinations as vac
on dea.date = vac.date and dea.location = vac.location
group by dea.continent, dea.location
order by tot_vac



--CTE's

with PopvsVac (continent, location, date, population, new_vac, tot_vac)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as float))
	over (partition by dea.location order by dea.date) as tot_vac
from CovidDeaths as dea join CovidVaccinations as vac
on dea.date = vac.date and dea.location = vac.location
where dea.continent is not null
--order by 2,3
)
select *, (tot_vac/population)*100 as percentage_of_vac
from PopvsVac
--group by continent, location
order by 2,3



-- Temp table

drop table if exists #perc_of_ppl_vaccinated
create table #perc_of_ppl_vaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population float,
new_vaccinations bigint,
tot_vac float
)

insert into #perc_of_ppl_vaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as float))
	over (partition by dea.location order by dea.date) as tot_vac
from CovidDeaths as dea join CovidVaccinations as vac
on dea.date = vac.date and dea.location = vac.location
where dea.continent is not null
--order by 2,3

select *, (tot_vac/population)*100 perc_of_vac
from #perc_of_ppl_vaccinated


-- creating View to store data for later visualizations

create view perc_of_ppl_vaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as float))
	over (partition by dea.location order by dea.date) as tot_vac
from CovidDeaths as dea join CovidVaccinations as vac
on dea.date = vac.date and dea.location = vac.location
where dea.continent is not null
--order by 2,3

select continent, location, max(cast(tot_vac as bigint)) as tot_vac
from perc_of_ppl_vaccinated
group by continent, location
order by 3
