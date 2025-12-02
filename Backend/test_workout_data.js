const mysql = require('mysql2/promise');

(async () => {
  const conn = await mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '', // .env 파일이 없어서 빈 비밀번호 사용
    database: 'q_pt'
  });

  console.log('=== WorkoutPlan Table ===');
  const [plans] = await conn.query(`
    SELECT plan_id, user_id, plan_date, status, memo 
    FROM WorkoutPlan 
    WHERE user_id = 1 
    ORDER BY plan_date DESC 
    LIMIT 5
  `);
  console.table(plans);

  console.log('\n=== PlannedSet Count by Date ===');
  const [counts] = await conn.query(`
    SELECT 
      wp.plan_date, 
      wp.status as plan_status, 
      COUNT(ps.set_id) as total_sets,
      SUM(CASE WHEN ps.status = 'completed' THEN 1 ELSE 0 END) as completed_sets,
      SUM(CASE WHEN ps.status = 'pending' THEN 1 ELSE 0 END) as pending_sets,
      SUM(CASE WHEN ps.status = 'skipped' THEN 1 ELSE 0 END) as skipped_sets
    FROM WorkoutPlan wp 
    LEFT JOIN PlannedSet ps ON wp.plan_id = ps.plan_id 
    WHERE wp.user_id = 1 
      AND wp.plan_date >= CURDATE() - INTERVAL 7 DAY 
    GROUP BY wp.plan_id 
    ORDER BY wp.plan_date DESC
  `);
  console.table(counts);

  console.log('\n=== PlannedSet Detail (Last 7 Days) ===');
  const [sets] = await conn.query(`
    SELECT 
      wp.plan_date, 
      e.exercise_name, 
      ps.set_number, 
      ps.status,
      ps.target_weight_kg,
      ps.actual_weight_kg, 
      ps.actual_reps
    FROM WorkoutPlan wp 
    JOIN PlannedSet ps ON wp.plan_id = ps.plan_id 
    JOIN Exercise e ON ps.exercise_id = e.exercise_id 
    WHERE wp.user_id = 1 
      AND wp.plan_date >= CURDATE() - INTERVAL 7 DAY 
    ORDER BY wp.plan_date DESC, ps.display_order, ps.set_number
  `);
  console.table(sets);

  console.log('\n=== Weekly Summary ===');
  const [summary] = await conn.query(`
    SELECT 
      COUNT(DISTINCT wp.plan_id) as workout_days,
      COUNT(ps.set_id) as total_sets,
      SUM(CASE WHEN ps.status = 'completed' THEN 1 ELSE 0 END) as completed_sets,
      SUM(CASE WHEN ps.status = 'pending' THEN 1 ELSE 0 END) as pending_sets,
      SUM(CASE WHEN ps.status = 'skipped' THEN 1 ELSE 0 END) as skipped_sets
    FROM WorkoutPlan wp
    JOIN PlannedSet ps ON wp.plan_id = ps.plan_id
    WHERE wp.user_id = 1 
      AND wp.plan_date >= CURDATE() - INTERVAL 7 DAY
  `);
  console.table(summary);

  await conn.end();
})();

