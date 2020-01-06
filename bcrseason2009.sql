
/*
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

--table to store the filter to t_diski table
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

declare @t_teams_rolling table(
         season         smallint 
        ,club           varchar(50)
        ,goalscored     smallint
)

--table to store club nicknames, useful for a much fancier bar chart race, club logos will also go into that table
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


select           @filter_num            = 2
                ,@sql_filter            = '';

--if temp table exists drop it
if object_id('tempdb..#t_diski_filtered') is not null
begin
        drop table  #t_diski_filtered;
end
;

create table #t_diski_filtered (
         season         smallint    null
        ,home           varchar(50) null
        ,visitor        varchar(50) null
        ,fthg           tinyint     null
        ,ftag           tinyint     null
        ,dateplayed     date        null
) 
;

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
select 'Ajax Cape Town' club,'urban warriors' nick union
select 'Amazulu','usuthu' union
select 'Baroka FC','bakgakga' union
select 'Bidvest Wits','the clever boys' union
select 'Black Leopards','lidoda duvha' union
select 'Bloemfontein Celtic','phunya selesele' union
select 'Cape Town City','the citizens' union
select 'Chippa United','chilli boys' union
select 'Free State Stars','ea lla koto' union
select 'Golden Arrows','abafana besthende' union
select 'Highlands Park','lions of the north' union
select 'Jomo Cosmos','ezenkosi' union
select 'Kaizer Chiefs','amakhosi' union
select 'Mamelodi Sundowns','the brazilians' union
select 'Maritzburg United','team of choice' union
select 'Moroka Swallows','the dube birds' union
select 'Mpumalanga Black Aces','amazayoni' union
select 'Orlando Pirates','amabhakabhaka' union
select 'Platinum Stars','dikwena' union
select 'Polokwane City','rise and shine' union
select 'Santos','jou lekker ding' union
select 'Stellenbosch','stellies' union
select 'SuperSport United','matsatsantsa' union
select 'University of Pretoria','amatuks' union
select 'Vasco da Gama','vasco' 

--update @t_nick
--set nickname = concat(nickname,' ')

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
inner join      @t_teams_rolling combined
on              t.season                = combined.season
and             t.club                  = combined.club
 


select           season         as [year]
                ,club           as [name]
                ,goalscored     as SeasonGoalScored
                ,sum(goalscored) over(  partition by  club order by season 
                                        rows between unbounded preceding and current row) [value]  --key window function that gives the rolling sums by team
                ,teamnick       [group]
from             @t_teams t
order by         club
                ,season asc

/*
select  *
from    @t_nick
*/





















