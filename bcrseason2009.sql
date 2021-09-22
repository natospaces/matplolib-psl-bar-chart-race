
/*

this is the structure of a typical football match csv for example so the idea of the script is to transform this to a structure easier to use for the bar chart source data

create table dbo.t_diski(
	 matchid        int identity(1,1) not null primary key
	,season         smallint null
	,home           varchar(50) null
	,visitor        varchar(50) null
	,fulltime       varchar(50) null
	,fthg           tinyint null
	,ftag           tinyint null
	,result         varchar(50) null
	,dateplayed     date null
) 
*/

declare  @sql_filter    nvarchar(2000)
        ,@filter_num    tinyint

/*
	table variable storing the dynamical sql generated filter 
	to apply on the t_diski table
*/
declare @t_date_filter table
(
          num                   tinyint 
         ,[description]         varchar(150)
         ,filter_text           varchar(150)
)

declare @t_teams table(
         season         smallint 
        ,club           varchar(50)
        ,goalscored     smallint
        ,teamnick       nvarchar(50)
)

/*
	table variable storing club goals scored running totals
*/

declare @t_teams_rolling table(
         season         smallint 
        ,club           varchar(50)
        ,goalscored     smallint
)

/*
	table variable storing club nicknames, can be extended to have an extra column like a varbinary field to store a clubs logo file for example 
*/
declare @t_nick table
(
         club           nvarchar(100)
        ,nickname       nvarchar(100)
)

insert @t_date_filter
(
         num 
        ,[description]
        ,filter_text
)
select          1,'starting from 2009 season'   ,concat(char(10)        ,'where d.season        >= 2009') union  --filters by starting from the beginning of 2009-2010 season
select          2,'starting from 1 Jan 2010'    ,concat(char(10)        ,'where d.dateplayed    >= ''31-Dec-2009'' ')  --filters by starting from the beginning of the year 2010 

--selecting second filter
select           @filter_num            = 2
                ,@sql_filter            = '';

--if temp table exists drop it
if object_id('tempdb..#t_diski_filtered') is not null
begin
        drop table  #t_diski_filtered;
end
;

/*
	temp table with same structure as typical football match result information
*/
create table #t_diski_filtered (
         season         smallint    null
        ,home           varchar(50) null
        ,visitor        varchar(50) null
        ,fthg           tinyint     null
        ,ftag           tinyint     null
        ,dateplayed     date        null
) 
;

/*
	dynamic sql to filter the data
		- reason for using dynamic sql is cater for all kinds of fancy filters
		- replicate function used to for clean looking generated sql since 
		  debugging dynamic sql can be challenging without proper formatting

*/
select      @sql_filter = concat(    @sql_filter                
                                ,'insert  #t_diski_filtered(',char(10)
                                ,replicate(char(32),6),' season',char(10)
                                ,replicate(char(32),6),',home',char(10)
                                ,replicate(char(32),6),',visitor',char(10)
                                ,replicate(char(32),6),',fthg',char(10)
                                ,replicate(char(32),6),',ftag',char(10)
                                ,replicate(char(32),6),',dateplayed',char(10)
                                ,')',char(10)
                                ,'select d.season ',char(10)
                                ,replicate(char(32),6),',d.home',char(10)
                                ,replicate(char(32),6),',d.visitor',char(10)
                                ,replicate(char(32),6),',d.fthg',char(10)
                                ,replicate(char(32),6),',d.ftag',char(10)
                                ,replicate(char(32),6),',d.dateplayed',char(10)
                                ,'from  dbo.t_diski d'
                                ,df.filter_text
                                )
from        @t_date_filter df
where       df.num                      = @filter_num
 
exec sp_executesql       @sql           = @sql_filter

/*

	inserting all the teams in the filter 
	-- cross join used for all seasaon for factoring 
	   the running total for season when a team is relegated

*/
insert @t_teams
(
         club
        ,season
        ,goalscored
)
select   hfilt.club
        ,sfilt.Season
        ,0
from 
        (       select  distinct home           as club
                from    #t_diski_filtered
        ) hfilt
cross join
        (
                select  distinct season
                from    #t_diski_filtered     
        ) sfilt

insert @t_nick(  
         club
        ,nickname
)
select 'Ajax Cape Town' club,'Urban Warriors' nick union
select 'Amazulu','Usuthu' union
select 'Baroka FC','Bakgakga' union
select 'Bidvest Wits','The Clever Boys' union
select 'Black Leopards','Lidoda Duvha' union
select 'Bloemfontein Celtic','Phunya Selesele' union
select 'Cape Town City','The Citizens' union
select 'Chippa United','Chilli Boys' union
select 'Free State Stars','Ea Lla Koto' union
select 'Golden Arrows','Abafana Besthende' union
select 'Highlands Park','Lions of the North' union
select 'Jomo Cosmos','Ezenkosi' union
select 'Kaizer Chiefs','Amakhosi' union
select 'Mamelodi Sundowns','The Brazilians' union
select 'Maritzburg United','Team of Choice' union
select 'Moroka Swallows','The Dube Birds' union
select 'Mpumalanga Black Aces','Amazayoni' union
select 'Orlando Pirates','Amabhakabhaka' union
select 'Platinum Stars','Dikwena' union
select 'Polokwane City','Rise and Shine' union
select 'Santos','Jou Lekker Ding' union
select 'Stellenbosch','Stellies' union
select 'SuperSport United','Matsatsantsa' union
select 'University of Pretoria','Amatuks' union
select 'Vasco da Gama','Vasco' 


update  t
set     teamnick          = n.nickname
from    @t_teams t
inner join
        @t_nick n
on      t.club          = n.club 
;

--nested cte to combine home and visitor goals for each club
with cte 
as 
(       
        select          sum(fthg)               as goalscored
                       ,season                  as season 
                       ,home                    as club
        from            #t_diski_filtered
        group by        season
                       ,home
        union all
        select          sum(ftag)               as goalscored
                       ,season                  as season
                       ,visitor                 as club
        from            #t_diski_filtered
        group by        season
                       ,visitor
)
, combined 
as 
(
        select           gs.season 
                        ,gs.club                as club
                        ,sum(goalscored)        as goalscored
        from cte gs
        group by         season 
                        ,club
)
insert @t_teams_rolling
(
                 season
                ,club
                ,goalscored
)
select           c.season
                ,c.club
                ,sum(c.goalscored)
from            combined c
group by         c.season
                ,c.club
order by         c.club
                ,c.season asc

update          t
set             goalscored              = combined.goalscored
from            @t_teams t
inner join      
				@t_teams_rolling combined
on              t.season                = combined.season
and             t.club                  = combined.club
 


select           season         as [Year]
                ,club           as [Club]
                ,goalscored     as [Goals Scored]
                ,sum(goalscored) over(  partition by  club order by season 
                                        rows between unbounded preceding and current row) [Goals Scored Running Total]  --key window function that gives the rolling sums by team
                ,teamnick       Nickname
from             @t_teams t
order by         club
                ,season asc


















