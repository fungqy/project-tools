# 生成故事完成时长表数据
STORIES_COMPLETE_DURATION_SQL = """
insert into stories_complete_duration
select
    t3.project_id,
    t3.project_name,
    t2.sprint_id,
    t2.sprint_name,
    t1.story_id,
	t1.story_key,
	t2.story_name,
	t1.story_create_time,
	t1.story_complete_time,
	t1.story_complete_duration,
    CONCAT_WS('',
        CASE WHEN FLOOR((t1.story_complete_duration + 43200) / 86400) > 0
             THEN CONCAT(FLOOR((t1.story_complete_duration + 43200) / 86400), '天')
             ELSE '' END,
        CASE WHEN FLOOR((t1.story_complete_duration + 43200) / 86400) > 0
             THEN CONCAT(FLOOR(((t1.story_complete_duration + 1800) % 86400) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((t1.story_complete_duration + 43200) / 86400) = 0
             AND FLOOR((t1.story_complete_duration + 30) / 3600) > 0
             THEN CONCAT(FLOOR((t1.story_complete_duration + 30) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((t1.story_complete_duration + 43200) / 86400) = 0
             AND FLOOR(((t1.story_complete_duration + 30) % 3600) / 60) > 0
             THEN CONCAT(FLOOR(((t1.story_complete_duration + 30) % 3600) / 60), '分')
             ELSE '' END
    ) AS story_complete_duration_str,
    t1.story_complete_duration_all,
    CONCAT_WS('',
        CASE WHEN FLOOR((t1.story_complete_duration_all + 43200) / 86400) > 0
             THEN CONCAT(FLOOR((t1.story_complete_duration_all + 43200) / 86400), '天')
             ELSE '' END,
        CASE WHEN FLOOR((t1.story_complete_duration_all + 43200) / 86400) > 0
             THEN CONCAT(FLOOR(((t1.story_complete_duration_all + 1800) % 86400) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((t1.story_complete_duration_all + 43200) / 86400) = 0
             AND FLOOR((t1.story_complete_duration_all + 30) / 3600) > 0
             THEN CONCAT(FLOOR((t1.story_complete_duration_all + 30) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((t1.story_complete_duration_all + 43200) / 86400) = 0
             AND FLOOR(((t1.story_complete_duration_all + 30) % 3600) / 60) > 0
             THEN CONCAT(FLOOR(((t1.story_complete_duration_all + 30) % 3600) / 60), '分')
             ELSE '' END
    ) AS story_complete_duration_all_str
from
(   SELECT
        t.story_id,
        t.story_key,
        t.change_time as story_create_time,
        t.story_complete_time,
        SUM(CASE
              WHEN di.isholiday = 1 OR (di.weekday IN (6, 7) AND di.iscompday = 0) THEN 0
              ELSE TIMESTAMPDIFF(SECOND,
                     GREATEST(t.change_time, CONCAT(di.datestr, ' 00:00:00')),
                     LEAST(t.story_complete_time, CONCAT(di.datestr, ' 23:59:59'))
                   )
              END
        ) AS story_complete_duration,
        SUM(TIMESTAMPDIFF(SECOND,
              GREATEST(t.change_time, CONCAT(di.datestr, ' 00:00:00')),
              LEAST(t.story_complete_time, CONCAT(di.datestr, ' 23:59:59'))
            )
        ) AS story_complete_duration_all
    FROM
    (
		select * from rdm_storie_changelog where log_id = 1 and story_complete_time is not null
	) t
    JOIN
        holidays di
    ON
        di.datestr BETWEEN DATE(t.change_time)
    AND
        DATE(t.story_complete_time)
    GROUP BY
        t.story_id, t.story_key, t.change_time, t.story_complete_time
) t1
left join
(
	select
		issueId,
        issueKey,
        issueName as story_name,
        sprint_id,
        sprint_name,
        ROW_NUMBER() OVER(partition by issueId, issueKey order by sprint_id desc) rn
    from rdmdb.rdm_issue
)  t2
on
	t1.story_id = t2.issueId
and
	t1.story_key = t2.issueKey
and
	t2.rn = 1
left JOIN
	rdmdb.rdm_sprint t3
on
	t2.sprint_id = t3.sprint_id
"""

# 生成故障完成时长表数据
BUGS_COMPLETE_DURATION_SQL = """
insert into bugs_complete_duration
WITH
t_bugs AS (
	select t.* from
	(select t.* ,row_number() over(partition by sprint_id, bug_id, change_detail order by change_time desc) rn
	 from rdmdb.rdm_bug_changelog t
     where bug_name not like '%视觉%'
     and (change_type = 'create' or change_detail in ('待测试 -> 完成', '处理中 -> 待测试'))
	) t
	where rn = 1
),
t_bugs_create_time AS (select * from t_bugs where change_type = 'create'),
t_bugs_finish_time AS (select * from t_bugs where change_detail = '待测试 -> 完成'),
t_bugs_test_time AS (select * from t_bugs where change_detail = '处理中 -> 待测试'),
t_sprint_seqno AS (select project_id, sprint_id, short_sprint_name, row_number() over(partition by project_id order by sprint_id) sprint_seqno from rdmdb.rdm_sprint),
t_main AS (
            select
                t1.project_id,
            	t1.project_name,
                t1.sprint_id,
            	t1.sprint_name,
            	t4.short_sprint_name,
            	t4.sprint_seqno,
	        	t1.bug_id,
                t1.bug_key,
                t1.bug_name,
                replace(t1.bug_solver, 'OLD', '') author,
            	t3.change_time as create_time,
            	t2.change_time as test_time,
            	t1.change_time as finish_time
            from t_bugs_finish_time t1
            inner join t_bugs_test_time t2
            on t1.sprint_id = t2.sprint_id and t1.bug_id = t2.bug_id
            inner join t_bugs_create_time t3
            on t1.sprint_id = t3.sprint_id and t1.bug_id = t3.bug_id
            left join t_sprint_seqno t4
            on t1.project_id = t4.project_id and t1.sprint_id = t4.sprint_id
          )
select
    dev.*,
	test.test_seconds_all,
    test.test_seconds,
	finish.finish_seconds_all,
	finish.finish_seconds,
    CONCAT_WS('',
        CASE WHEN FLOOR((dev.dev_seconds_all + 43200) / 86400) > 0
             THEN CONCAT(FLOOR((dev.dev_seconds_all + 43200) / 86400), '天')
             ELSE '' END,
        CASE WHEN FLOOR((dev.dev_seconds_all + 43200) / 86400) > 0
             THEN CONCAT(FLOOR(((dev.dev_seconds_all + 1800) % 86400) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((dev.dev_seconds_all + 43200) / 86400) = 0
             AND FLOOR((dev.dev_seconds_all + 30) / 3600) > 0
             THEN CONCAT(FLOOR((dev.dev_seconds_all + 30) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((dev.dev_seconds_all + 43200) / 86400) = 0
             AND FLOOR(((dev.dev_seconds_all + 30) % 3600) / 60) > 0
             THEN CONCAT(FLOOR(((dev.dev_seconds_all + 30) % 3600) / 60), '分')
             ELSE '' END
    ) AS dev_time_all_str,
    CONCAT_WS('',
        CASE WHEN FLOOR((test.test_seconds_all + 43200) / 86400) > 0
             THEN CONCAT(FLOOR((test.test_seconds_all + 43200) / 86400), '天')
             ELSE '' END,
        CASE WHEN FLOOR((test.test_seconds_all + 43200) / 86400) > 0
             THEN CONCAT(FLOOR(((test.test_seconds_all + 1800) % 86400) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((test.test_seconds_all + 43200) / 86400) = 0
             AND FLOOR((test.test_seconds_all + 30) / 3600) > 0
             THEN CONCAT(FLOOR((test.test_seconds_all + 30) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((test.test_seconds_all + 43200) / 86400) = 0
             AND FLOOR(((test.test_seconds_all + 30) % 3600) / 60) > 0
             THEN CONCAT(FLOOR(((test.test_seconds_all + 30) % 3600) / 60), '分')
             ELSE '' END
    ) AS test_time_all_str,
    CONCAT_WS('',
        CASE WHEN FLOOR((finish.finish_seconds_all + 43200) / 86400) > 0
             THEN CONCAT(FLOOR((finish.finish_seconds_all + 43200) / 86400), '天')
             ELSE '' END,
        CASE WHEN FLOOR((finish.finish_seconds_all + 43200) / 86400) > 0
             THEN CONCAT(FLOOR(((finish.finish_seconds_all + 1800) % 86400) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((finish.finish_seconds_all + 43200) / 86400) = 0
             AND FLOOR((finish.finish_seconds_all + 30) / 3600) > 0
             THEN CONCAT(FLOOR((finish.finish_seconds_all + 30) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((finish.finish_seconds_all + 43200) / 86400) = 0
             AND FLOOR(((finish.finish_seconds_all + 30) % 3600) / 60) > 0
             THEN CONCAT(FLOOR(((finish.finish_seconds_all + 30) % 3600) / 60), '分')
             ELSE '' END
    ) AS finish_time_all_str,
    CONCAT_WS('',
        CASE WHEN FLOOR((dev.dev_seconds + 43200) / 86400) > 0
             THEN CONCAT(FLOOR((dev.dev_seconds + 43200) / 86400), '天')
             ELSE '' END,
        CASE WHEN FLOOR((dev.dev_seconds + 43200) / 86400) > 0
             THEN CONCAT(FLOOR(((dev.dev_seconds + 1800) % 86400) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((dev.dev_seconds + 43200) / 86400) = 0
             AND FLOOR((dev.dev_seconds + 30) / 3600) > 0
             THEN CONCAT(FLOOR((dev.dev_seconds + 30) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((dev.dev_seconds + 43200) / 86400) = 0
             AND FLOOR(((dev.dev_seconds + 30) % 3600) / 60) > 0
             THEN CONCAT(FLOOR(((dev.dev_seconds + 30) % 3600) / 60), '分')
             ELSE '' END
    ) AS dev_time_str,
    CONCAT_WS('',
        CASE WHEN FLOOR((test.test_seconds + 43200) / 86400) > 0
             THEN CONCAT(FLOOR((test.test_seconds + 43200) / 86400), '天')
             ELSE '' END,
        CASE WHEN FLOOR((test.test_seconds + 43200) / 86400) > 0
             THEN CONCAT(FLOOR(((test.test_seconds + 1800) % 86400) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((test.test_seconds + 43200) / 86400) = 0
             AND FLOOR((test.test_seconds + 30) / 3600) > 0
             THEN CONCAT(FLOOR((test.test_seconds + 30) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((test.test_seconds + 43200) / 86400) = 0
             AND FLOOR(((test.test_seconds + 30) % 3600) / 60) > 0
             THEN CONCAT(FLOOR(((test.test_seconds + 30) % 3600) / 60), '分')
             ELSE '' END
    ) AS test_time_str,
    CONCAT_WS('',
        CASE WHEN FLOOR((finish.finish_seconds + 43200) / 86400) > 0
             THEN CONCAT(FLOOR((finish.finish_seconds + 43200) / 86400), '天')
             ELSE '' END,
        CASE WHEN FLOOR((finish.finish_seconds + 43200) / 86400) > 0
             THEN CONCAT(FLOOR(((finish.finish_seconds + 1800) % 86400) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((finish.finish_seconds + 43200) / 86400) = 0
             AND FLOOR((finish.finish_seconds + 30) / 3600) > 0
             THEN CONCAT(FLOOR((finish.finish_seconds + 30) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((finish.finish_seconds + 43200) / 86400) = 0
             AND FLOOR(((finish.finish_seconds + 30) % 3600) / 60) > 0
             THEN CONCAT(FLOOR(((finish.finish_seconds + 30) % 3600) / 60), '分')
             ELSE '' END
    ) AS finish_time_str
from
(
    select
        t.*,
	    SUM(TIMESTAMPDIFF(SECOND,
              GREATEST(t.create_time, CONCAT(dev.datestr, ' 00:00:00')),
              LEAST(t.test_time, CONCAT(dev.datestr, ' 23:59:59')))
        ) AS dev_seconds_all,
	    SUM(CASE
              WHEN dev.isholiday = 1 OR (dev.weekday IN (6, 7) AND dev.iscompday = 0) THEN 0
              ELSE TIMESTAMPDIFF(SECOND,
                     GREATEST(t.create_time, CONCAT(dev.datestr, ' 00:00:00')),
                     LEAST(t.test_time, CONCAT(dev.datestr, ' 23:59:59')))
            END
        ) AS dev_seconds
    from t_main t
    join holidays dev
    on dev.datestr between date(t.create_time) and date(t.test_time)
	group by
        t.project_id,
        t.project_name,
        t.sprint_id,
        t.sprint_name,
        t.sprint_seqno,
	    t.bug_id,
        t.bug_key,
        t.bug_name,
        t.author,
        t.create_time,
        t.test_time,
        t.finish_time
) dev
left join
(
    select
        t.*,
	    SUM(TIMESTAMPDIFF(SECOND,
              GREATEST(t.test_time, CONCAT(test.datestr, ' 00:00:00')),
              LEAST(t.finish_time, CONCAT(test.datestr, ' 23:59:59')))
        ) AS test_seconds_all,
	    SUM(CASE
              WHEN test.isholiday = 1 OR (test.weekday IN (6, 7) AND test.iscompday = 0) THEN 0
              ELSE TIMESTAMPDIFF(SECOND,
                     GREATEST(t.test_time, CONCAT(test.datestr, ' 00:00:00')),
                     LEAST(t.finish_time, CONCAT(test.datestr, ' 23:59:59')))
            END
        ) AS test_seconds
    from t_main t
    join holidays test
    on test.datestr between date(t.test_time) and date(t.finish_time)
	group by
        t.project_id,
        t.sprint_id,
	    t.bug_id,
        t.test_time,
        t.finish_time
) test
on dev.project_id = test.project_id and dev.sprint_id = test.sprint_id and dev.bug_id = test.bug_id
left join
(
    select
        t.*,
	    SUM(TIMESTAMPDIFF(SECOND,
              GREATEST(t.create_time, CONCAT(finish.datestr, ' 00:00:00')),
              LEAST(t.finish_time, CONCAT(finish.datestr, ' 23:59:59')))
        ) AS finish_seconds_all,
	    SUM(CASE
              WHEN finish.isholiday = 1 OR (finish.weekday IN (6, 7) AND finish.iscompday = 0) THEN 0
              ELSE TIMESTAMPDIFF(SECOND,
                     GREATEST(t.create_time, CONCAT(finish.datestr, ' 00:00:00')),
                     LEAST(t.finish_time, CONCAT(finish.datestr, ' 23:59:59')))
            END
        ) AS finish_seconds
    from t_main t
    join holidays finish
    on finish.datestr between date(t.create_time) and date(t.finish_time)
	group by
        t.project_id,
        t.sprint_id,
	    t.bug_id,
        t.create_time,
        t.finish_time
) finish
on dev.project_id = finish.project_id and dev.sprint_id = finish.sprint_id and dev.bug_id = finish.bug_id
"""

# 生成各Sprint故障评价完成时长表数据
SPRINTS_BUGS_AVG_COMPLETE_DURATION_SQL = """
insert into sprints_bugs_avg_complete_duration
select
    project_id,
    project_name,
    sprint_id,
    sprint_name,
    short_sprint_name,
    sprint_seqno,
    dev_seconds_all,
    dev_seconds,
    test_seconds_all,
    test_seconds,
    finish_seconds_all,
    finish_seconds,
    CONCAT_WS('',
        CASE WHEN FLOOR((dev_seconds_all + 43200) / 86400) > 0
             THEN CONCAT(FLOOR((dev_seconds_all + 43200) / 86400), '天')
             ELSE '' END,
        CASE WHEN FLOOR((dev_seconds_all + 43200) / 86400) > 0
             THEN CONCAT(FLOOR(((dev_seconds_all + 1800) % 86400) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((dev_seconds_all + 43200) / 86400) = 0
             AND FLOOR((dev_seconds_all + 30) / 3600) > 0
             THEN CONCAT(FLOOR((dev_seconds_all + 30) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((dev_seconds_all + 43200) / 86400) = 0
             AND FLOOR(((dev_seconds_all + 30) % 3600) / 60) > 0
             THEN CONCAT(FLOOR(((dev_seconds_all + 30) % 3600) / 60), '分')
             ELSE '' END
    ) AS dev_time_all_str,
    CONCAT_WS('',
        CASE WHEN FLOOR((test_seconds_all + 43200) / 86400) > 0
             THEN CONCAT(FLOOR((test_seconds_all + 43200) / 86400), '天')
             ELSE '' END,
        CASE WHEN FLOOR((test_seconds_all + 43200) / 86400) > 0
             THEN CONCAT(FLOOR(((test_seconds_all + 1800) % 86400) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((test_seconds_all + 43200) / 86400) = 0
             AND FLOOR((test_seconds_all + 30) / 3600) > 0
             THEN CONCAT(FLOOR((test_seconds_all + 30) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((test_seconds_all + 43200) / 86400) = 0
             AND FLOOR(((test_seconds_all + 30) % 3600) / 60) > 0
             THEN CONCAT(FLOOR(((test_seconds_all + 30) % 3600) / 60), '分')
             ELSE '' END
    ) AS test_time_all_str,
    CONCAT_WS('',
        CASE WHEN FLOOR((finish_seconds_all + 43200) / 86400) > 0
             THEN CONCAT(FLOOR((finish_seconds_all + 43200) / 86400), '天')
             ELSE '' END,
        CASE WHEN FLOOR((finish_seconds_all + 43200) / 86400) > 0
             THEN CONCAT(FLOOR(((finish_seconds_all + 1800) % 86400) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((finish_seconds_all + 43200) / 86400) = 0
             AND FLOOR((finish_seconds_all + 30) / 3600) > 0
             THEN CONCAT(FLOOR((finish_seconds_all + 30) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((finish_seconds_all + 43200) / 86400) = 0
             AND FLOOR(((finish_seconds_all + 30) % 3600) / 60) > 0
             THEN CONCAT(FLOOR(((finish_seconds_all + 30) % 3600) / 60), '分')
             ELSE '' END
    ) AS finish_time_all_str,
    CONCAT_WS('',
        CASE WHEN FLOOR((dev_seconds + 43200) / 86400) > 0
             THEN CONCAT(FLOOR((dev_seconds + 43200) / 86400), '天')
             ELSE '' END,
        CASE WHEN FLOOR((dev_seconds + 43200) / 86400) > 0
             THEN CONCAT(FLOOR(((dev_seconds + 1800) % 86400) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((dev_seconds + 43200) / 86400) = 0
             AND FLOOR((dev_seconds + 30) / 3600) > 0
             THEN CONCAT(FLOOR((dev_seconds + 30) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((dev_seconds + 43200) / 86400) = 0
             AND FLOOR(((dev_seconds + 30) % 3600) / 60) > 0
             THEN CONCAT(FLOOR(((dev_seconds + 30) % 3600) / 60), '分')
             ELSE '' END
    ) AS dev_time_str,
    CONCAT_WS('',
        CASE WHEN FLOOR((test_seconds + 43200) / 86400) > 0
             THEN CONCAT(FLOOR((test_seconds + 43200) / 86400), '天')
             ELSE '' END,
        CASE WHEN FLOOR((test_seconds + 43200) / 86400) > 0
             THEN CONCAT(FLOOR(((test_seconds + 1800) % 86400) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((test_seconds + 43200) / 86400) = 0
             AND FLOOR((test_seconds + 30) / 3600) > 0
             THEN CONCAT(FLOOR((test_seconds + 30) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((test_seconds + 43200) / 86400) = 0
             AND FLOOR(((test_seconds + 30) % 3600) / 60) > 0
             THEN CONCAT(FLOOR(((test_seconds + 30) % 3600) / 60), '分')
             ELSE '' END
    ) AS test_time_str,
    CONCAT_WS('',
        CASE WHEN FLOOR((finish_seconds + 43200) / 86400) > 0
             THEN CONCAT(FLOOR((finish_seconds + 43200) / 86400), '天')
             ELSE '' END,
        CASE WHEN FLOOR((finish_seconds + 43200) / 86400) > 0
             THEN CONCAT(FLOOR(((finish_seconds + 1800) % 86400) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((finish_seconds + 43200) / 86400) = 0
             AND FLOOR((finish_seconds + 30) / 3600) > 0
             THEN CONCAT(FLOOR((finish_seconds + 30) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((finish_seconds + 43200) / 86400) = 0
             AND FLOOR(((finish_seconds + 30) % 3600) / 60) > 0
             THEN CONCAT(FLOOR(((finish_seconds + 30) % 3600) / 60), '分')
             ELSE '' END
    ) AS finish_time_str
from
(
    select
        project_id,
        project_name,
        sprint_id,
        sprint_name,
        short_sprint_name,
        sprint_seqno,
        FLOOR(avg(dev_seconds_all)) as dev_seconds_all,
        FLOOR(avg(dev_seconds)) as dev_seconds,
        FLOOR(avg(test_seconds_all)) as test_seconds_all,
        FLOOR(avg(test_seconds)) as test_seconds,
        FLOOR(avg(finish_seconds_all)) as finish_seconds_all,
        FLOOR(avg(finish_seconds)) as finish_seconds
    from bugs_complete_duration
    group by
        project_id,
        project_name,
        sprint_id,
        sprint_name,
        short_sprint_name,
        sprint_seqno
) t
"""

# 生成各开发人员的故障平均完成时长表的数据
AUTHORS_BUGS_AVG_COMPLETE_DURATION_SQL = """
insert into authors_bugs_avg_complete_duration
select
    project_id,
    project_name,
    sprint_id,
    sprint_name,
    short_sprint_name,
    sprint_seqno,
    author,
    bug_count,
    dev_seconds_all,
    dev_seconds,
    test_seconds_all,
    test_seconds,
    finish_seconds_all,
    finish_seconds,
    CONCAT_WS('',
        CASE WHEN FLOOR((dev_seconds_all + 43200) / 86400) > 0
             THEN CONCAT(FLOOR((dev_seconds_all + 43200) / 86400), '天')
             ELSE '' END,
        CASE WHEN FLOOR((dev_seconds_all + 43200) / 86400) > 0
             THEN CONCAT(FLOOR(((dev_seconds_all + 1800) % 86400) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((dev_seconds_all + 43200) / 86400) = 0
             AND FLOOR((dev_seconds_all + 30) / 3600) > 0
             THEN CONCAT(FLOOR((dev_seconds_all + 30) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((dev_seconds_all + 43200) / 86400) = 0
             AND FLOOR(((dev_seconds_all + 30) % 3600) / 60) > 0
             THEN CONCAT(FLOOR(((dev_seconds_all + 30) % 3600) / 60), '分')
             ELSE '' END
    ) AS dev_time_all_str,
    CONCAT_WS('',
        CASE WHEN FLOOR((test_seconds_all + 43200) / 86400) > 0
             THEN CONCAT(FLOOR((test_seconds_all + 43200) / 86400), '天')
             ELSE '' END,
        CASE WHEN FLOOR((test_seconds_all + 43200) / 86400) > 0
             THEN CONCAT(FLOOR(((test_seconds_all + 1800) % 86400) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((test_seconds_all + 43200) / 86400) = 0
             AND FLOOR((test_seconds_all + 30) / 3600) > 0
             THEN CONCAT(FLOOR((test_seconds_all + 30) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((test_seconds_all + 43200) / 86400) = 0
             AND FLOOR(((test_seconds_all + 30) % 3600) / 60) > 0
             THEN CONCAT(FLOOR(((test_seconds_all + 30) % 3600) / 60), '分')
             ELSE '' END
    ) AS test_time_all_str,
    CONCAT_WS('',
        CASE WHEN FLOOR((finish_seconds_all + 43200) / 86400) > 0
             THEN CONCAT(FLOOR((finish_seconds_all + 43200) / 86400), '天')
             ELSE '' END,
        CASE WHEN FLOOR((finish_seconds_all + 43200) / 86400) > 0
             THEN CONCAT(FLOOR(((finish_seconds_all + 1800) % 86400) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((finish_seconds_all + 43200) / 86400) = 0
             AND FLOOR((finish_seconds_all + 30) / 3600) > 0
             THEN CONCAT(FLOOR((finish_seconds_all + 30) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((finish_seconds_all + 43200) / 86400) = 0
             AND FLOOR(((finish_seconds_all + 30) % 3600) / 60) > 0
             THEN CONCAT(FLOOR(((finish_seconds_all + 30) % 3600) / 60), '分')
             ELSE '' END
    ) AS finish_time_all_str,
    CONCAT_WS('',
        CASE WHEN FLOOR((dev_seconds + 43200) / 86400) > 0
             THEN CONCAT(FLOOR((dev_seconds + 43200) / 86400), '天')
             ELSE '' END,
        CASE WHEN FLOOR((dev_seconds + 43200) / 86400) > 0
             THEN CONCAT(FLOOR(((dev_seconds + 1800) % 86400) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((dev_seconds + 43200) / 86400) = 0
             AND FLOOR((dev_seconds + 30) / 3600) > 0
             THEN CONCAT(FLOOR((dev_seconds + 30) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((dev_seconds + 43200) / 86400) = 0
             AND FLOOR(((dev_seconds + 30) % 3600) / 60) > 0
             THEN CONCAT(FLOOR(((dev_seconds + 30) % 3600) / 60), '分')
             ELSE '' END
    ) AS dev_time_str,
    CONCAT_WS('',
        CASE WHEN FLOOR((test_seconds + 43200) / 86400) > 0
             THEN CONCAT(FLOOR((test_seconds + 43200) / 86400), '天')
             ELSE '' END,
        CASE WHEN FLOOR((test_seconds + 43200) / 86400) > 0
             THEN CONCAT(FLOOR(((test_seconds + 1800) % 86400) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((test_seconds + 43200) / 86400) = 0
             AND FLOOR((test_seconds + 30) / 3600) > 0
             THEN CONCAT(FLOOR((test_seconds + 30) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((test_seconds + 43200) / 86400) = 0
             AND FLOOR(((test_seconds + 30) % 3600) / 60) > 0
             THEN CONCAT(FLOOR(((test_seconds + 30) % 3600) / 60), '分')
             ELSE '' END
    ) AS test_time_str,
    CONCAT_WS('',
        CASE WHEN FLOOR((finish_seconds + 43200) / 86400) > 0
             THEN CONCAT(FLOOR((finish_seconds + 43200) / 86400), '天')
             ELSE '' END,
        CASE WHEN FLOOR((finish_seconds + 43200) / 86400) > 0
             THEN CONCAT(FLOOR(((finish_seconds + 1800) % 86400) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((finish_seconds + 43200) / 86400) = 0
             AND FLOOR((finish_seconds + 30) / 3600) > 0
             THEN CONCAT(FLOOR((finish_seconds + 30) / 3600), '小时')
             ELSE '' END,
        CASE WHEN FLOOR((finish_seconds + 43200) / 86400) = 0
             AND FLOOR(((finish_seconds + 30) % 3600) / 60) > 0
             THEN CONCAT(FLOOR(((finish_seconds + 30) % 3600) / 60), '分')
             ELSE '' END
    ) AS finish_time_str
from
(
    select
        project_id,
        project_name,
        sprint_id,
        sprint_name,
        short_sprint_name,
        sprint_seqno,
        author,
        count(1) as bug_count,
        FLOOR(avg(dev_seconds_all)) as dev_seconds_all,
        FLOOR(avg(dev_seconds)) as dev_seconds,
        FLOOR(avg(test_seconds_all)) as test_seconds_all,
        FLOOR(avg(test_seconds)) as test_seconds,
        FLOOR(avg(finish_seconds_all)) as finish_seconds_all,
        FLOOR(avg(finish_seconds)) as finish_seconds
    from bugs_complete_duration
    group by
        project_id,
        project_name,
        sprint_id,
        sprint_name,
        short_sprint_name,
        sprint_seqno,
        author
) t
"""
