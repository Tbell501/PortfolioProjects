Select *
From [Portfolio Project]..CovidDeaths
Where continent is not null
order by 3,4

--Select *
--From [Portfolio Project]..CovidVaccinations
--order by 3,4




Select Location, date, total_cases, new_cases, total_deaths,population
From [Portfolio Project]..CovidDeaths
order by 1,2



Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
From [Portfolio Project]..CovidDeaths
order by 1,2

--Total Cases vs Total Deaths

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
From [Portfolio Project]..CovidDeaths
Where location like '%state%'
order by 1,2

-- Total Cases vs Population

Select Location, date, population, total_cases, (total_cases/population)*100 as deathpercentage
From [Portfolio Project]..CovidDeaths
--Where location like '%state%'
order by 1,2

 --Countries with Highest Infection Rate compared to Population

Select Location, population, max(total_cases) as highestinfectioncount, Max((total_cases/population))*100 as deathpercentage
From [Portfolio Project]..CovidDeaths
--Where location like '%state%'
group by location, population
order by 1,2

-- Countries with Highest Death Count per Population

Select location, max(cast(total_deaths as int)) as totaldeathcount
From [Portfolio Project]..CovidDeaths
--Where location like '%state%'
Where continent is null
group by location
order by totaldeathcount desc

--Showing contintents with the highest death count per population

Select continent, max(cast(total_deaths as int)) as totaldeathcount
From [Portfolio Project]..CovidDeaths
--Where location like '%state%'
Where continent is not null
group by continent
order by totaldeathcount desc



Select date, sum(new_cases), sum(cast(new_deaths as int)), sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by date
order by 1,2



Select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by date
order by 1,2


Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage
From [Portfolio Project]..CovidDeaths
--Where location like '%states%'
Where continent is not null
--Group by date
order by 1,2

 --Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,	sum(cast(vac.new_vaccinations as bigint)) over (partition by dea.location)
from [Portfolio Project]..coviddeaths dea
join [Portfolio Project]..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
 dea.date)
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM [Portfolio Project]..CovidDeaths AS dea
JOIN [Portfolio Project]..CovidVaccinations AS vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3;



SELECT location, MAX(total_deaths) as TotalDeathCount
FROM [Portfolio Project]..CovidDeaths
WHERE continent is not NULL
GROUP BY location
ORDER BY TotalDeathCount DESC;



--Using CTE to perform Calculation on Partition By in previous query

with popvsvac (Continent, location, date, population, new_vacinnations, rollingpeoplevacinnated) as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
 dea.date) as rollingpeoplevacinnated
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
) 
select *
From popvsvac


with popvsvac (Continent, location, date, population, new_vacinnations, rollingpeoplevacinnated) as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
 dea.date) as rollingpeoplevacinnated
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
) 
select *, (rollingpeoplevacinnated/population)*100
From popvsvac

--- Using Temp Table to perform Calculation on Partition By in previous query


Drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevacinnated numeric
)

insert into #percentpopulationvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
 dea.date) as rollingpeoplevacinnated
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (rollingpeoplevacinnated/population)*100
From #percentpopulationvaccinated


--Creating View to store data for later visualizations

Create view percentpopulationvaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(float, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
 dea.date) as rollingpeoplevacinnated
from [Portfolio Project]..CovidDeaths dea
join [Portfolio Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


Select *
From percentpopulationvaccinated