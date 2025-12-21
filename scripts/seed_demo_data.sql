-- Demo data seed for JwSystemPublic (safe for local/dev use).
-- Inserts additional teacher_course + t_score + absent + notice records
-- to make dashboards/schedules less empty.

SET @team_id := '2';
SET @week_id := '1';
SET @classes_id := '1735850905920147458';

SET @teacher_a := '1004';   -- 教师
SET @teacher_b := '10001';  -- 讲师（登录身份仍选“教师”）

SET @class_size := (SELECT COUNT(*) FROM t_student WHERE classes_id = @classes_id);

-- Unique-ish seed token for titles (kept short; classroom column is varchar(11)).
SET @seed_token := DATE_FORMAT(NOW(), '%H%i%S');

-- Section slots (t_section.id)
SET @sec_a1 := '1';   -- 周一 1-2
SET @sec_a2 := '7';   -- 周二 3-4
SET @sec_a3 := '13';  -- 周三 5-6
SET @sec_a4 := '19';  -- 周四 7-8
SET @sec_a5 := '25';  -- 周五 9-10

SET @sec_b1 := '2';   -- 周一 3-4
SET @sec_b2 := '8';   -- 周二 5-6
SET @sec_b3 := '14';  -- 周三 7-8
SET @sec_b4 := '20';  -- 周四 9-10
SET @sec_b5 := '21';  -- 周五 1-2

-- Courses (t_course.id) with different system_id to diversify student dashboard.
SET @c_sys1 := '1221309074533359618'; -- 大学英语Ⅰ (system_id=1)
SET @c_sys2 := '1221318535016730625'; -- Java Web编程技术 (system_id=2)
SET @c_sys4 := '1221317261080776705'; -- 大学生心理健康教育 (system_id=4)
SET @c_sys5 := '1221321372903788545'; -- 创新创业项目实践 (system_id=5)
SET @c_sys6 := '1221318140391444482'; -- 编译原理 (system_id=6)

-- ========= teacher_course (10) =========
SET @tc_a1 := REPLACE(UUID(), '-', '');
SET @tc_a2 := REPLACE(UUID(), '-', '');
SET @tc_a3 := REPLACE(UUID(), '-', '');
SET @tc_a4 := REPLACE(UUID(), '-', '');
SET @tc_a5 := REPLACE(UUID(), '-', '');

SET @tc_b1 := REPLACE(UUID(), '-', '');
SET @tc_b2 := REPLACE(UUID(), '-', '');
SET @tc_b3 := REPLACE(UUID(), '-', '');
SET @tc_b4 := REPLACE(UUID(), '-', '');
SET @tc_b5 := REPLACE(UUID(), '-', '');

INSERT INTO teacher_course
  (id, team_id, teacher_id, week_id, section_id, end, comment, cid, people, total_people, classroom, status, apply, classes_id, is_classes)
VALUES
  (@tc_a1, @team_id, @teacher_a, @week_id, @sec_a1, 2, 0, @c_sys1, 0, @class_size + 10, CONCAT('E2E', @seed_token, 'A1'), 1, 1, @classes_id, 1),
  (@tc_a2, @team_id, @teacher_a, @week_id, @sec_a2, 0, 0, @c_sys2, 0, @class_size + 10, CONCAT('E2E', @seed_token, 'A2'), 1, 1, @classes_id, 1),
  (@tc_a3, @team_id, @teacher_a, @week_id, @sec_a3, 0, 0, @c_sys4, 0, @class_size + 10, CONCAT('E2E', @seed_token, 'A3'), 1, 1, @classes_id, 1),
  (@tc_a4, @team_id, @teacher_a, @week_id, @sec_a4, 2, 0, @c_sys5, 0, @class_size + 10, CONCAT('E2E', @seed_token, 'A4'), 1, 1, @classes_id, 1),
  (@tc_a5, @team_id, @teacher_a, @week_id, @sec_a5, 0, 0, @c_sys6, 0, @class_size + 10, CONCAT('E2E', @seed_token, 'A5'), 1, 1, @classes_id, 1),
  (@tc_b1, @team_id, @teacher_b, @week_id, @sec_b1, 2, 0, @c_sys4, 0, @class_size + 10, CONCAT('E2E', @seed_token, 'B1'), 1, 1, @classes_id, 1),
  (@tc_b2, @team_id, @teacher_b, @week_id, @sec_b2, 0, 0, @c_sys6, 0, @class_size + 10, CONCAT('E2E', @seed_token, 'B2'), 1, 1, @classes_id, 1),
  (@tc_b3, @team_id, @teacher_b, @week_id, @sec_b3, 0, 0, @c_sys1, 0, @class_size + 10, CONCAT('E2E', @seed_token, 'B3'), 1, 1, @classes_id, 1),
  (@tc_b4, @team_id, @teacher_b, @week_id, @sec_b4, 2, 0, @c_sys2, 0, @class_size + 10, CONCAT('E2E', @seed_token, 'B4'), 1, 1, @classes_id, 1),
  (@tc_b5, @team_id, @teacher_b, @week_id, @sec_b5, 0, 0, @c_sys5, 0, @class_size + 10, CONCAT('E2E', @seed_token, 'B5'), 1, 1, @classes_id, 1);

-- ========= teacher_course (extra pending flows) =========
-- Add a pending “开课申请”(apply=0) and a pending “结课申请”(end=1)
-- so admin/教务相关页面默认不为空。
SET @teacher_demo := '9'; -- 教师：苏老师
SET @tc_pending_apply := REPLACE(UUID(), '-', '');
SET @tc_pending_end := REPLACE(UUID(), '-', '');

INSERT INTO teacher_course
  (id, team_id, teacher_id, week_id, section_id, end, comment, cid, people, total_people, classroom, status, apply, classes_id, is_classes)
VALUES
  -- 开课申请：待审核
  (@tc_pending_apply, @team_id, @teacher_demo, @week_id, @sec_b4, 0, 0, @c_sys4, 0, 60, CONCAT('E2E', @seed_token, 'P0'), 1, 0, NULL, 0),
  -- 结课申请：待审核（end=1）
  (@tc_pending_end, @team_id, @teacher_demo, @week_id, @sec_b5, 1, 0, @c_sys1, 0, 60, CONCAT('E2E', @seed_token, 'E1'), 1, 1, NULL, 0);

-- ========= t_score + absent (per teacher_course) =========
-- Deterministic pseudo-random helpers based on CRC32 to make scores/absences stable.
-- absent_cnt: 0..2
-- score: 60..100

-- helper numbers table (1..2) for expanding absent events
DROP TEMPORARY TABLE IF EXISTS tmp_nums2;
CREATE TEMPORARY TABLE tmp_nums2 (n INT PRIMARY KEY);
INSERT INTO tmp_nums2 (n) VALUES (1), (2);

-- Seed for a single course offering
-- NOTE: keep inserts separated to reuse per-course sectionId & teacherId.
-- teacher A
INSERT INTO t_score (course_id, student_id, teacher_id, attendance, usually, exam, score, absent, status, point)
SELECT
  @tc_a1, s.sid, @teacher_a,
  10 AS attendance,
  20 AS usually,
  sc.score - 30 AS exam,
  sc.score,
  sc.absent_cnt AS absent,
  1 AS status,
  ROUND(sc.score / 20, 1) AS point
FROM (
  SELECT
    sid,
    60 + MOD(CRC32(CONCAT('score', @tc_a1, sid)), 41) AS score,
    MOD(CRC32(CONCAT('abs', @tc_a1, sid)), 3) AS absent_cnt
  FROM t_student
  WHERE classes_id = @classes_id
) sc
JOIN t_student s ON s.sid = sc.sid;

INSERT INTO absent (id, cid, sid, tid, create_time, sectionId, status, description, team_id)
SELECT
  REPLACE(UUID(), '-', ''), @tc_a1, s.sid, @teacher_a,
  DATE_SUB(CURDATE(), INTERVAL MOD(CRC32(CONCAT('dt', @tc_a1, s.sid, n.n)), 7) DAY),
  @sec_a1, 1, CONCAT('E2E seed ', @seed_token), @team_id
FROM (
  SELECT sid, MOD(CRC32(CONCAT('abs', @tc_a1, sid)), 3) AS absent_cnt
  FROM t_student
  WHERE classes_id = @classes_id
) s
JOIN tmp_nums2 n ON n.n <= s.absent_cnt;

INSERT INTO t_score (course_id, student_id, teacher_id, attendance, usually, exam, score, absent, status, point)
SELECT
  @tc_a2, s.sid, @teacher_a,
  10, 20,
  sc.score - 30,
  sc.score,
  sc.absent_cnt,
  1,
  ROUND(sc.score / 20, 1)
FROM (
  SELECT sid,
         60 + MOD(CRC32(CONCAT('score', @tc_a2, sid)), 41) AS score,
         MOD(CRC32(CONCAT('abs', @tc_a2, sid)), 3) AS absent_cnt
  FROM t_student
  WHERE classes_id = @classes_id
) sc
JOIN t_student s ON s.sid = sc.sid;

INSERT INTO absent (id, cid, sid, tid, create_time, sectionId, status, description, team_id)
SELECT
  REPLACE(UUID(), '-', ''), @tc_a2, s.sid, @teacher_a,
  DATE_SUB(CURDATE(), INTERVAL MOD(CRC32(CONCAT('dt', @tc_a2, s.sid, n.n)), 7) DAY),
  @sec_a2, 1, CONCAT('E2E seed ', @seed_token), @team_id
FROM (
  SELECT sid, MOD(CRC32(CONCAT('abs', @tc_a2, sid)), 3) AS absent_cnt
  FROM t_student
  WHERE classes_id = @classes_id
) s
JOIN tmp_nums2 n ON n.n <= s.absent_cnt;

INSERT INTO t_score (course_id, student_id, teacher_id, attendance, usually, exam, score, absent, status, point)
SELECT
  @tc_a3, s.sid, @teacher_a,
  10, 20,
  sc.score - 30,
  sc.score,
  sc.absent_cnt,
  1,
  ROUND(sc.score / 20, 1)
FROM (
  SELECT sid,
         60 + MOD(CRC32(CONCAT('score', @tc_a3, sid)), 41) AS score,
         MOD(CRC32(CONCAT('abs', @tc_a3, sid)), 3) AS absent_cnt
  FROM t_student
  WHERE classes_id = @classes_id
) sc
JOIN t_student s ON s.sid = sc.sid;

INSERT INTO absent (id, cid, sid, tid, create_time, sectionId, status, description, team_id)
SELECT
  REPLACE(UUID(), '-', ''), @tc_a3, s.sid, @teacher_a,
  DATE_SUB(CURDATE(), INTERVAL MOD(CRC32(CONCAT('dt', @tc_a3, s.sid, n.n)), 7) DAY),
  @sec_a3, 1, CONCAT('E2E seed ', @seed_token), @team_id
FROM (
  SELECT sid, MOD(CRC32(CONCAT('abs', @tc_a3, sid)), 3) AS absent_cnt
  FROM t_student
  WHERE classes_id = @classes_id
) s
JOIN tmp_nums2 n ON n.n <= s.absent_cnt;

INSERT INTO t_score (course_id, student_id, teacher_id, attendance, usually, exam, score, absent, status, point)
SELECT
  @tc_a4, s.sid, @teacher_a,
  10, 20,
  sc.score - 30,
  sc.score,
  sc.absent_cnt,
  1,
  ROUND(sc.score / 20, 1)
FROM (
  SELECT sid,
         60 + MOD(CRC32(CONCAT('score', @tc_a4, sid)), 41) AS score,
         MOD(CRC32(CONCAT('abs', @tc_a4, sid)), 3) AS absent_cnt
  FROM t_student
  WHERE classes_id = @classes_id
) sc
JOIN t_student s ON s.sid = sc.sid;

INSERT INTO absent (id, cid, sid, tid, create_time, sectionId, status, description, team_id)
SELECT
  REPLACE(UUID(), '-', ''), @tc_a4, s.sid, @teacher_a,
  DATE_SUB(CURDATE(), INTERVAL MOD(CRC32(CONCAT('dt', @tc_a4, s.sid, n.n)), 7) DAY),
  @sec_a4, 1, CONCAT('E2E seed ', @seed_token), @team_id
FROM (
  SELECT sid, MOD(CRC32(CONCAT('abs', @tc_a4, sid)), 3) AS absent_cnt
  FROM t_student
  WHERE classes_id = @classes_id
) s
JOIN tmp_nums2 n ON n.n <= s.absent_cnt;

INSERT INTO t_score (course_id, student_id, teacher_id, attendance, usually, exam, score, absent, status, point)
SELECT
  @tc_a5, s.sid, @teacher_a,
  10, 20,
  sc.score - 30,
  sc.score,
  sc.absent_cnt,
  1,
  ROUND(sc.score / 20, 1)
FROM (
  SELECT sid,
         60 + MOD(CRC32(CONCAT('score', @tc_a5, sid)), 41) AS score,
         MOD(CRC32(CONCAT('abs', @tc_a5, sid)), 3) AS absent_cnt
  FROM t_student
  WHERE classes_id = @classes_id
) sc
JOIN t_student s ON s.sid = sc.sid;

INSERT INTO absent (id, cid, sid, tid, create_time, sectionId, status, description, team_id)
SELECT
  REPLACE(UUID(), '-', ''), @tc_a5, s.sid, @teacher_a,
  DATE_SUB(CURDATE(), INTERVAL MOD(CRC32(CONCAT('dt', @tc_a5, s.sid, n.n)), 7) DAY),
  @sec_a5, 1, CONCAT('E2E seed ', @seed_token), @team_id
FROM (
  SELECT sid, MOD(CRC32(CONCAT('abs', @tc_a5, sid)), 3) AS absent_cnt
  FROM t_student
  WHERE classes_id = @classes_id
) s
JOIN tmp_nums2 n ON n.n <= s.absent_cnt;

-- teacher B
INSERT INTO t_score (course_id, student_id, teacher_id, attendance, usually, exam, score, absent, status, point)
SELECT
  @tc_b1, s.sid, @teacher_b,
  10, 20,
  sc.score - 30,
  sc.score,
  sc.absent_cnt,
  1,
  ROUND(sc.score / 20, 1)
FROM (
  SELECT sid,
         60 + MOD(CRC32(CONCAT('score', @tc_b1, sid)), 41) AS score,
         MOD(CRC32(CONCAT('abs', @tc_b1, sid)), 3) AS absent_cnt
  FROM t_student
  WHERE classes_id = @classes_id
) sc
JOIN t_student s ON s.sid = sc.sid;

INSERT INTO absent (id, cid, sid, tid, create_time, sectionId, status, description, team_id)
SELECT
  REPLACE(UUID(), '-', ''), @tc_b1, s.sid, @teacher_b,
  DATE_SUB(CURDATE(), INTERVAL MOD(CRC32(CONCAT('dt', @tc_b1, s.sid, n.n)), 7) DAY),
  @sec_b1, 1, CONCAT('E2E seed ', @seed_token), @team_id
FROM (
  SELECT sid, MOD(CRC32(CONCAT('abs', @tc_b1, sid)), 3) AS absent_cnt
  FROM t_student
  WHERE classes_id = @classes_id
) s
JOIN tmp_nums2 n ON n.n <= s.absent_cnt;

INSERT INTO t_score (course_id, student_id, teacher_id, attendance, usually, exam, score, absent, status, point)
SELECT
  @tc_b2, s.sid, @teacher_b,
  10, 20,
  sc.score - 30,
  sc.score,
  sc.absent_cnt,
  1,
  ROUND(sc.score / 20, 1)
FROM (
  SELECT sid,
         60 + MOD(CRC32(CONCAT('score', @tc_b2, sid)), 41) AS score,
         MOD(CRC32(CONCAT('abs', @tc_b2, sid)), 3) AS absent_cnt
  FROM t_student
  WHERE classes_id = @classes_id
) sc
JOIN t_student s ON s.sid = sc.sid;

INSERT INTO absent (id, cid, sid, tid, create_time, sectionId, status, description, team_id)
SELECT
  REPLACE(UUID(), '-', ''), @tc_b2, s.sid, @teacher_b,
  DATE_SUB(CURDATE(), INTERVAL MOD(CRC32(CONCAT('dt', @tc_b2, s.sid, n.n)), 7) DAY),
  @sec_b2, 1, CONCAT('E2E seed ', @seed_token), @team_id
FROM (
  SELECT sid, MOD(CRC32(CONCAT('abs', @tc_b2, sid)), 3) AS absent_cnt
  FROM t_student
  WHERE classes_id = @classes_id
) s
JOIN tmp_nums2 n ON n.n <= s.absent_cnt;

INSERT INTO t_score (course_id, student_id, teacher_id, attendance, usually, exam, score, absent, status, point)
SELECT
  @tc_b3, s.sid, @teacher_b,
  10, 20,
  sc.score - 30,
  sc.score,
  sc.absent_cnt,
  1,
  ROUND(sc.score / 20, 1)
FROM (
  SELECT sid,
         60 + MOD(CRC32(CONCAT('score', @tc_b3, sid)), 41) AS score,
         MOD(CRC32(CONCAT('abs', @tc_b3, sid)), 3) AS absent_cnt
  FROM t_student
  WHERE classes_id = @classes_id
) sc
JOIN t_student s ON s.sid = sc.sid;

INSERT INTO absent (id, cid, sid, tid, create_time, sectionId, status, description, team_id)
SELECT
  REPLACE(UUID(), '-', ''), @tc_b3, s.sid, @teacher_b,
  DATE_SUB(CURDATE(), INTERVAL MOD(CRC32(CONCAT('dt', @tc_b3, s.sid, n.n)), 7) DAY),
  @sec_b3, 1, CONCAT('E2E seed ', @seed_token), @team_id
FROM (
  SELECT sid, MOD(CRC32(CONCAT('abs', @tc_b3, sid)), 3) AS absent_cnt
  FROM t_student
  WHERE classes_id = @classes_id
) s
JOIN tmp_nums2 n ON n.n <= s.absent_cnt;

INSERT INTO t_score (course_id, student_id, teacher_id, attendance, usually, exam, score, absent, status, point)
SELECT
  @tc_b4, s.sid, @teacher_b,
  10, 20,
  sc.score - 30,
  sc.score,
  sc.absent_cnt,
  1,
  ROUND(sc.score / 20, 1)
FROM (
  SELECT sid,
         60 + MOD(CRC32(CONCAT('score', @tc_b4, sid)), 41) AS score,
         MOD(CRC32(CONCAT('abs', @tc_b4, sid)), 3) AS absent_cnt
  FROM t_student
  WHERE classes_id = @classes_id
) sc
JOIN t_student s ON s.sid = sc.sid;

INSERT INTO absent (id, cid, sid, tid, create_time, sectionId, status, description, team_id)
SELECT
  REPLACE(UUID(), '-', ''), @tc_b4, s.sid, @teacher_b,
  DATE_SUB(CURDATE(), INTERVAL MOD(CRC32(CONCAT('dt', @tc_b4, s.sid, n.n)), 7) DAY),
  @sec_b4, 1, CONCAT('E2E seed ', @seed_token), @team_id
FROM (
  SELECT sid, MOD(CRC32(CONCAT('abs', @tc_b4, sid)), 3) AS absent_cnt
  FROM t_student
  WHERE classes_id = @classes_id
) s
JOIN tmp_nums2 n ON n.n <= s.absent_cnt;

INSERT INTO t_score (course_id, student_id, teacher_id, attendance, usually, exam, score, absent, status, point)
SELECT
  @tc_b5, s.sid, @teacher_b,
  10, 20,
  sc.score - 30,
  sc.score,
  sc.absent_cnt,
  1,
  ROUND(sc.score / 20, 1)
FROM (
  SELECT sid,
         60 + MOD(CRC32(CONCAT('score', @tc_b5, sid)), 41) AS score,
         MOD(CRC32(CONCAT('abs', @tc_b5, sid)), 3) AS absent_cnt
  FROM t_student
  WHERE classes_id = @classes_id
) sc
JOIN t_student s ON s.sid = sc.sid;

INSERT INTO absent (id, cid, sid, tid, create_time, sectionId, status, description, team_id)
SELECT
  REPLACE(UUID(), '-', ''), @tc_b5, s.sid, @teacher_b,
  DATE_SUB(CURDATE(), INTERVAL MOD(CRC32(CONCAT('dt', @tc_b5, s.sid, n.n)), 7) DAY),
  @sec_b5, 1, CONCAT('E2E seed ', @seed_token), @team_id
FROM (
  SELECT sid, MOD(CRC32(CONCAT('abs', @tc_b5, sid)), 3) AS absent_cnt
  FROM t_student
  WHERE classes_id = @classes_id
) s
JOIN tmp_nums2 n ON n.n <= s.absent_cnt;

-- Update enrolled counts (people) to match class size.
UPDATE teacher_course
SET people = @class_size
WHERE id IN (@tc_a1, @tc_a2, @tc_a3, @tc_a4, @tc_a5, @tc_b1, @tc_b2, @tc_b3, @tc_b4, @tc_b5);

-- ========= notices =========
-- JW panel filters by publisher's collegeId; user id=3 is in college 16935.
INSERT INTO notice (id, title, create_time, update_time, status, publisher, content, html_content)
VALUES
  (REPLACE(UUID(), '-', ''), CONCAT('E2E演示通知-', @seed_token, '-1'), CURDATE(), CURDATE(), 1, '3',
   '本通知由脚本自动生成，用于演示仪表盘公告列表。',
   '<p>本通知由脚本自动生成，用于演示仪表盘公告列表。</p>'),
  (REPLACE(UUID(), '-', ''), CONCAT('E2E演示通知-', @seed_token, '-2'), CURDATE(), CURDATE(), 1, '3',
   '课程、成绩与考勤已补充演示数据，可在学生/教师/教务端查看。',
   '<p>课程、成绩与考勤已补充演示数据，可在学生/教师/教务端查看。</p>'),
  (REPLACE(UUID(), '-', ''), CONCAT('E2E演示通知-', @seed_token, '-3'), CURDATE(), CURDATE(), 1, '3',
   '如需清理演示数据，可按 classroom=E2E% 或 description=E2E seed% 定位。',
   '<p>如需清理演示数据，可按 <code>classroom=E2E%</code> 或 <code>description=E2E seed%</code> 定位。</p>');

-- ========= quick summary =========
SELECT 'seed_teacher_course_added' AS k, COUNT(*) AS v FROM teacher_course WHERE classroom LIKE 'E2E%';
SELECT 'seed_scores_added' AS k, COUNT(*) AS v FROM t_score WHERE course_id IN (@tc_a1, @tc_a2, @tc_a3, @tc_a4, @tc_a5, @tc_b1, @tc_b2, @tc_b3, @tc_b4, @tc_b5);
SELECT 'seed_absent_added' AS k, COUNT(*) AS v FROM absent WHERE description LIKE CONCAT('E2E seed ', @seed_token, '%');
