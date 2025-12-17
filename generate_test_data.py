#!/usr/bin/env python3
"""
JwSystem测试数据批量生成脚本 v2
基于实际数据库schema精确编写
"""

import pymysql
import random
from faker import Faker
from datetime import datetime
import os

# 数据库配置
DB_CONFIG = {
    'host': '127.0.0.1',
    'port': 3306,
    'user': 'jw_user',
    # 从环境变量读取，避免在仓库中存放凭据
    'password': os.environ.get('JW_DB_PASSWORD', ''),
    'database': 'jw_springboot',
    'charset': 'utf8mb4'
}

# 数据生成配置
NUM_STUDENTS = 200
NUM_TEACHERS = 30
NUM_CLASSES = 20
COURSES_PER_STUDENT = 6

fake = Faker('zh_CN')

def get_connection():
    """获取数据库连接"""
    if not DB_CONFIG.get('password'):
        raise RuntimeError("缺少数据库密码：请先设置环境变量 JW_DB_PASSWORD")
    return pymysql.connect(**DB_CONFIG)

def fetch_existing_data(conn):
    """获取现有基础数据 - 使用准确的字段名"""
    with conn.cursor() as cursor:
        # t_college: id, name, status
        cursor.execute("SELECT id, name FROM t_college WHERE status='1'")
        colleges = cursor.fetchall()
        
        # t_specialty: id, name, time, category, college_id, status
        cursor.execute("SELECT id, name FROM t_specialty WHERE status='1'")
        specialties = cursor.fetchall()
        
        # t_grade: id, name
        cursor.execute("SELECT id, name FROM t_grade")
        grades = cursor.fetchall()
        
        # t_course: id, name, credit, ...
        cursor.execute("SELECT id, name, credit FROM t_course WHERE status=1")
        courses = cursor.fetchall()
        
        # t_classes: id, classname, specialty_id, college_id, people, grade_id, year
        cursor.execute("SELECT id, classname FROM t_classes")
        existing_classes = cursor.fetchall()
        
    return {
        'colleges': colleges,
        'specialties': specialties,
        'grades': grades,
        'courses': courses,
        'existing_classes': existing_classes
    }

def generate_classes(conn, data, num_classes):
    """生成班级数据 - t_classes(id, classname, specialty_id, college_id, people, grade_id, year)"""
    print(f"📚 生成 {num_classes} 个班级...")
    
    if len(data['existing_classes']) >= num_classes:
        print(f"  ✓ 已有 {len(data['existing_classes'])} 个班级，跳过生成")
        return data['existing_classes']
    
    classes = []
    with conn.cursor() as cursor:
        for i in range(num_classes):
            specialty = random.choice(data['specialties'])
            grade = random.choice(data['grades'])
            college = random.choice(data['colleges'])
            class_num = i + 1
            
            # 生成班级ID和名称
            class_id = f"CLS{grade[0]}{specialty[0][:4]}{class_num:02d}"
            class_name = f"{grade[1]}级{specialty[1]}{class_num}班"
            
            try:
                cursor.execute("""
                    INSERT INTO t_classes (id, classname, specialty_id, college_id, people, grade_id, year)
                    VALUES (%s, %s, %s, %s, 0, %s, %s)
                    ON DUPLICATE KEY UPDATE classname=VALUES(classname)
                """, (class_id, class_name, specialty[0], college[0], grade[0], grade[1]))
                classes.append((class_id, class_name))
                print(f"  ✓ 创建班级: {class_name}")
            except Exception as e:
                print(f"  ⚠ 班级 {class_name} 创建失败: {e}")
        
        conn.commit()
    
    print(f"  ✓ 班级创建完成，共 {len(classes)} 个")
    return classes + list(data['existing_classes'])

def generate_students(conn, classes, num_students):
    """生成学生数据 - t_student(sid, password, sname, sex, scity, qx, absent, classes_id, grade_id, ...)"""
    print(f"👨‍🎓 生成 {num_students} 个学生...")
    
    students = []
    with conn.cursor() as cursor:
        start_id = 20003  # 从20003开始避免冲突
        
        for i in range(num_students):
            student_id = str(start_id + i)
            name = fake.name()
            sex = random.choice(['男', '女'])
            city = fake.city()
            class_info = random.choice(classes)
            grade_id = random.choice(['2020', '2021', '2022', '2023'])
            begin_time = datetime(int(grade_id), 9, 1).date()
            phone = fake.phone_number()
            idcard = fake.ssn()
            address = fake.address()
            political = random.choice(['群众', '团员', '党员'])
            
            try:
                cursor.execute("""
                    INSERT INTO t_student 
                    (sid, password, sname, sex, scity, qx, absent, classes_id, grade_id, 
                     beginTime, phone, idcard, address, politicalStatus)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                    ON DUPLICATE KEY UPDATE sname=VALUES(sname)
                """, (student_id, '123456', name, sex, city, '学生', 
                      random.randint(0, 3), class_info[0], grade_id, 
                      begin_time, phone, idcard, address, political))
                students.append(student_id)
                
                if (i + 1) % 50 == 0:
                    print(f"  ... 已创建 {i + 1}/{num_students} 个学生")
                    
            except Exception as e:
                print(f"  ⚠ 学生 {student_id}-{name} 创建失败: {e}")
                continue
        
        conn.commit()
    
    print(f"  ✓ 学生创建完成，共 {len(students)} 个")
    return students

def generate_teachers(conn, data, num_teachers):
    """生成教师数据 - t_teacher(tid, password, tname, tsex, tage, status, college_id, qx, ...)"""
    print(f"👨‍🏫 生成 {num_teachers} 个教师...")
    
    teachers = []
    with conn.cursor() as cursor:
        start_id = 1004  # 从1004开始
        
        for i in range(num_teachers):
            teacher_id = str(start_id + i)
            name = fake.name()
            sex = random.choice(['男', '女'])
            age = str(random.randint(28, 60))
            college = random.choice(data['colleges'])
            
            try:
                cursor.execute("""
                    INSERT INTO t_teacher 
                    (tid, password, tname, tsex, tage, status, college_id, qx)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                    ON DUPLICATE KEY UPDATE tname=VALUES(tname)
                """, (teacher_id, '123456', name, sex, age, '1', college[0], '教师'))
                teachers.append(teacher_id)
                
            except Exception as e:
                print(f"  ⚠ 教师 {teacher_id}-{name} 创建失败: {e}")
                continue
        
        conn.commit()
    
    print(f"  ✓ 教师创建完成，共 {len(teachers)} 个")
    return teachers

def generate_scores(conn, students, teachers, courses):
    """生成选课和成绩数据 - t_score(course_id, student_id, teacher_id, attendance, usually, exam, score, ...)"""
    print(f"📝 生成选课和成绩数据...")
    
    count = 0
    with conn.cursor() as cursor:
        for idx, student_id in enumerate(students):
            # 每个学生随机选6门课
            num_courses = min(COURSES_PER_STUDENT, len(courses))
            selected_courses = random.sample(courses, num_courses)
            
            for course in selected_courses:
                teacher_id = random.choice(teachers)
                attendance = random.randint(8, 10)
                usually = random.randint(60, 95)
                exam = random.randint(50, 100)
                score = int(usually * 0.3 + exam * 0.7)
                point = round(max(0, (score - 50) / 10), 1)
                
                try:
                    cursor.execute("""
                        INSERT INTO t_score 
                        (course_id, student_id, teacher_id, attendance, usually, exam, score, absent, status, point)
                        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                        ON DUPLICATE KEY UPDATE score=VALUES(score), point=VALUES(point)
                    """, (course[0], student_id, teacher_id, attendance, usually, exam, score, 0, 1, point))
                    count += 1
                except Exception as e:
                    continue
            
            if (idx + 1) % 50 == 0:
                print(f"  ... 已处理 {idx + 1}/{len(students)} 个学生的选课")
                conn.commit()  # 分批提交
        
        conn.commit()
    
    print(f"  ✓ 生成了 {count} 条选课/成绩记录")
    return count

def verify_data(conn):
    """验证生成的数据"""
    print("\n" + "="*60)
    print("📊 最终数据统计")
    print("="*60)
    
    with conn.cursor() as cursor:
        cursor.execute("SELECT COUNT(*) FROM t_student")
        student_count = cursor.fetchone()[0]
        
        cursor.execute("SELECT COUNT(*) FROM t_teacher")
        teacher_count = cursor.fetchone()[0]
        
        cursor.execute("SELECT COUNT(*) FROM t_classes")
        class_count = cursor.fetchone()[0]
        
        cursor.execute("SELECT COUNT(*) FROM t_score")
        score_count = cursor.fetchone()[0]
        
        cursor.execute("SELECT COUNT(*) FROM t_course WHERE status=1")
        course_count = cursor.fetchone()[0]
        
    print(f"  📚 课程: {course_count}")
    print(f"  🏫 班级: {class_count}")
    print(f"  👨‍🎓 学生: {student_count}")
    print(f"  👨‍🏫 教师: {teacher_count}")
    print(f"  📝 选课记录: {score_count}")
    print("="*60)

def main():
    """主函数"""
    print("="*60)
    print("🚀 JwSystem 测试数据生成器 v2")
    print("="*60)
    
    try:
        conn = get_connection()
        print("✓ 数据库连接成功\n")
        
        # 1. 获取现有数据
        print("📖 读取基础数据...")
        data = fetch_existing_data(conn)
        print(f"  ✓ {len(data['colleges'])} 个学院")
        print(f"  ✓ {len(data['specialties'])} 个专业")
        print(f"  ✓ {len(data['grades'])} 个年级")
        print(f"  ✓ {len(data['courses'])} 门课程\n")
        
        # 2. 生成班级
        classes = generate_classes(conn, data, NUM_CLASSES)
        print()
        
        # 3. 生成学生
        students = generate_students(conn, classes, NUM_STUDENTS)
        print()
        
        # 4. 生成教师
        teachers = generate_teachers(conn, data, NUM_TEACHERS)
        print()
        
        # 5. 生成选课和成绩
        generate_scores(conn, students, teachers, data['courses'])
        
        # 6. 验证数据
        verify_data(conn)
        
        conn.close()
        
        print("\n✅ 数据生成完成！")
        print("\n🔑 测试账号 (所有密码: 123456):")
        print(f"  学生: 20001, 20002, 20003 ... {20002 + NUM_STUDENTS}")
        print(f"  教师: 1001, 1002, 1003, 1004 ... {1003 + NUM_TEACHERS}")
        print("  管理员: 1")
        print("\n现在可以登录系统查看数据了！")
        
    except Exception as e:
        print(f"\n❌ 错误: {e}")
        import traceback
        traceback.print_exc()

if __name__ == '__main__':
    main()
