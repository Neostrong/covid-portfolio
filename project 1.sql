-- showing all data from coviddeath table
select * from COVIDDEATHS$
--select * from COVIDDEATHS$ order by 3,4
select location, date, total_cases, new_cases, total_deaths, population from COVIDDEATHS$ order by 1,2

--totalcases vs totaldeaths, showing the likelyhood of getting covid in nigeria
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage 
from COVIDDEATHS$ where location like '%nigeria%' order by 1,2

--total case vs population in nigeria
select location, date, population, total_cases, (total_cases/population)*100 as case_percentage 
from COVIDDEATHS$ where location like '%nigeria%'


--Countries with highest infection rate
select location, population, max(total_cases) as highest_infection_count, max((total_cases/population)*100) as highest_infection_count_percent
from COVIDDEATHS$ group by location, population order by highest_infection_count_percent desc

--countries with the highest death per population
select location, population, max(cast(total_deaths as int)) as Deathcount
from COVIDDEATHS$ where continent is not null group by location, population order by deathcount desc

-- group death count by continents with highest deathcounts
select continent, max(cast(total_deaths as int)) as deathcount 
from COVIDDEATHS$ where continent is not null group by continent order by deathcount desc

--global numbers
select sum(new_cases) as totalnewcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as new_death_percent 
from COVIDDEATHS$ where continent is not null



--now to look at the second the second table covidvaccination
--joining 2 tables with common columns
select * 
from COVIDDEATHS$ d 
join COVIDVACCINATION$ v on d.location = v.location and d.date = v.date 

--looking at total population vs vaccination
select d.continent, d.location, d.date, d.population, v.new_vaccinations
from COVIDDEATHS$ d 
join COVIDVACCINATION$ v on d.location = v.location and d.date = v.date where d.continent is not null
order by 2,3

--rolling count syntax
select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(cast(v.new_vaccinations as float)) 
over(partition by d.location order by d.location, d.date) as repititive_sum_of_vaccination
from COVIDDEATHS$ d join COVIDVACCINATION$ v on d.location = v.location and d.date = v.date 
where d.continent is not null
order by 2,3

--putting a new column to work
with popvsvac (continent, location, date, population, new_vaccinations, repititive_sum_of_vaccination) 
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
sum(convert(float, v.new_vaccinations)) over (partition by d.location order by d.location, d.date) as repititive_sum_of_vaccination
from COVIDDEATHS$ d 
join COVIDVACCINATION$ v 
	on d.location = v.location 
	and d.date = v.date
where d.continent is not null)
select *, (repititive_sum_of_vaccination/population)*100 as rolling_percent from popvsvac


--temp table
drop table if exists #percentpopulatinvaccinated
create table #percentpopulatinvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population int,
new_vaccinations int,
repititive_sum_of_vaccination int
)
select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(cast(v.new_vaccinations as float)) 
over(partition by d.location order by d.location, d.date) as repititive_sum_of_vaccination
from COVIDDEATHS$ d join COVIDVACCINATION$ v on d.location = v.location and d.date = v.date 
where d.continent is not null
order by 2,3

select *, (repititive_sum_of_vaccination/population)*100 as rolling_percent from #percentpopulatinvaccinated
