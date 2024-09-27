-- Question 01: What’s the global (geographical) distribution of VR usage in education? Where is VR used the most for educational purposes?
SELECT 
    regions.Region, 
    COUNT(vr.Region) AS regions_using_VR_in_education
FROM 
    (SELECT DISTINCT Region FROM vr_usage) AS regions
LEFT JOIN 
    vr_usage vr ON regions.Region = vr.Region
    AND vr.Usage_of_VR_in_Education = 'Yes'
GROUP BY 
    regions.Region
ORDER BY 
    regions_using_VR_in_education DESC;
    
-- Question 02: Is there a subject for which VR is used the most or can be best applied for? Name the top 3 subjects for VR usage.
SELECT
    Subject, 
    COUNT(Subject) AS VR_subjects
FROM 
    subjects
WHERE
    Usage_of_VR_in_Education = 'Yes'
GROUP BY 
    Subject
ORDER BY 
    VR_subjects DESC
LIMIT 3;


-- Question 03: Overall, is there an improvement in academic performance to be seen by using VR?
SELECT
    COUNT(CASE WHEN Improvement_in_Learning_Outcomes = 'Yes' THEN 1 END) AS improvement_through_VR,
    COUNT(CASE WHEN Improvement_in_Learning_Outcomes = 'No' THEN 1 END) AS no_improvement_through_VR,
    ROUND(
        (COUNT(CASE WHEN Improvement_in_Learning_Outcomes = 'Yes' THEN 1 END) / COUNT(*)) * 100, 2 
    ) AS percentage_improved,  # calculating the % by counting the cases where the condition is met (boolean value = yes = 1) & rounding to two digits
    ROUND(
        (COUNT(CASE WHEN Improvement_in_Learning_Outcomes = 'No' THEN 1 END) / COUNT(*)) * 100, 2 # round to two decimal places
    ) AS percentage_not_improved
FROM 
    vr_usage
WHERE
    Usage_of_VR_in_Education = 'Yes';


-- Question 04: Is there a relation between the level of improvement in academic performance and students’ IT affinity?

# How to make assumptions on IT affinity now? > assumption: Computer Science students have a high affinity to IT. 
# How to measure acceptance? The stress level with VR usage should be low and the perceived effectiveness should be over 3 (of 5)
SELECT
    COUNT(CASE WHEN Perceived_Effectiveness_of_VR > 3 AND Stress_Level_with_VR_Usage = 'Low' THEN 1 END) AS well_accepted,
    COUNT(CASE WHEN Perceived_Effectiveness_of_VR < 3 AND Stress_Level_with_VR_Usage = 'High' THEN 1 END) AS not_well_accepted,
    ROUND(
        (COUNT(CASE WHEN Perceived_Effectiveness_of_VR > 3 AND Stress_Level_with_VR_Usage = 'Low' THEN 1 END) / 
        COUNT(*)) * 100, 2 # calculating the % by counting the cases where the condition is met (boolean value = yes = 1) & rounding to two decimal places
    ) AS percentage_accepted,
    ROUND(
        (COUNT(CASE WHEN Perceived_Effectiveness_of_VR < 3 AND Stress_Level_with_VR_Usage = 'High' THEN 1 END) / 
        COUNT(*)) * 100, 2 # calculating the percentage and rounding to two decimal places
    ) AS percentage_not_accepted
FROM 
    vr_usage
WHERE
    Usage_of_VR_in_Education = 'Yes' AND Subject = 'Computer Science';
    
    
-- Question 05: What is the overall acceptance rate of VR in students?

# Acceptance was measured the same way like in Question 04.
SELECT
    COUNT(CASE WHEN Perceived_Effectiveness_of_VR > 3 AND Stress_Level_with_VR_Usage = 'Low' THEN 1 END) AS well_accepted,
    ROUND(
        (COUNT(CASE WHEN Perceived_Effectiveness_of_VR > 3 AND Stress_Level_with_VR_Usage = 'Low' THEN 1 END) / 
        COUNT(*)) * 100, 2 # calculating the percentage by counting conditions met and rounding to two decimal places
	) AS percentage_accepted
    FROM 
    vr_usage
WHERE
    Usage_of_VR_in_Education = 'Yes';


-- Question 06: How many students experience issues like motion sickness when using VR and how does it affect the improvement of academic performance?

# The word is not about motion sickness but only stress level when using VR which can contain issues like motion sickness or feelings of oversaturation.
SELECT
    COUNT(CASE WHEN Improvement_in_Learning_Outcomes = 'Yes' THEN 1 END) AS improved_despite_stress,
    COUNT(CASE WHEN Improvement_in_Learning_Outcomes = 'No' THEN 1 END) AS not_improved,
    ROUND(
        (COUNT(CASE WHEN Improvement_in_Learning_Outcomes = 'Yes' THEN 1 END) / COUNT(*)) * 100, 2
    ) AS percentage_of_improvement_despite_stress,
    ROUND(
        (COUNT(CASE WHEN Improvement_in_Learning_Outcomes = 'No' THEN 1 END) / COUNT(*)) * 100, 2
    ) AS percentage_no_improvement
FROM 
    vr_usage
WHERE
    Usage_of_VR_in_Education = 'Yes' AND Stress_Level_with_VR_Usage = 'High';
# Conclusion: 50.90 compared to 49.10 percent means that it doesn't affect the improvement at all


-- Question 07: How many students have access to a VR device in private and how many students use VR frequently in their free time for games etc.?

# Since some students have a 'No' in usage of VR for education but anywas used hours per week, it leads to the assumption that it was used in private.

# first part: access to VR device in private
SELECT 
    COUNT(*) AS Access_to_VR_Equipment, 
    ROUND((COUNT(*) / 5000) * 100, 2) AS percentage_with_access
FROM
    vr_usage
WHERE
    Access_to_VR_Equipment = 'Yes';
    
# second part: how many use VR in free time?
SELECT 
    COUNT(*) AS Hours_of_Usage_Per_Week, 
    ROUND((COUNT(*) / 5000) * 100, 2) AS percentage_free_time_vr_users
FROM
    vr_usage
WHERE
    Usage_of_VR_in_Education = 'No' AND Hours_of_VR_Usage_Per_Week > 0;
# This tells us in the table there are 45.08% of people using VR ONLY in their free time, but from the table cannot be read how many use it 
# in education AND free time.


-- Question 08: Is there any difference between the interest in VR in gender?
SELECT 
    students.Gender,
    COUNT(*) AS Total_Students,
    SUM(CASE WHEN vr_usage.Usage_of_VR_in_Education = 'Yes' 
             AND vr_usage.Interest_in_Continuing_VR_Based_Learning = 'Yes' 
        THEN 1 ELSE 0 END) AS Interested_Students,
    ROUND(
        (SUM(CASE WHEN vr_usage.Usage_of_VR_in_Education = 'Yes' 
             AND vr_usage.Interest_in_Continuing_VR_Based_Learning = 'Yes' 
        THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2
    ) AS Percentage_Interested
FROM 
    students
JOIN 
    vr_usage ON students.Field_of_Study = vr_usage.Field_of_Study
GROUP BY 
    students.Gender;

-- Question 09: At which grade level and age is VR the most effective in education?
SELECT 
    students.Grade_Level,
    students.Age,
    COUNT(*) AS Total_Students,
    SUM(CASE WHEN vr_usage.Improvement_in_Learning_Outcomes = 'Yes' THEN 1 ELSE 0 END) AS Improved_Students,
    ROUND(
        (SUM(CASE WHEN vr_usage.Improvement_in_Learning_Outcomes = 'Yes' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2
    ) AS Improvement_Percentage
FROM 
    students
JOIN 
    vr_usage ON students.Field_of_Study = vr_usage.Field_of_Study
WHERE 
    vr_usage.Usage_of_VR_in_Education = 'Yes'
GROUP BY 
    students.Grade_Level, students.Age
ORDER BY 
    Improvement_Percentage DESC
LIMIT 1;


-- Question 10: Do students like to interact in VR or rather use it to learn things on their own?
SELECT 
    COUNT(*) AS Total_Students,
    SUM(CASE WHEN vr_usage.Collaboration_with_Peers_via_VR = 'Yes' THEN 1 ELSE 0 END) AS interacting_students,
    ROUND(
        (SUM(CASE WHEN vr_usage.Collaboration_with_Peers_via_VR = 'Yes' THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2
    ) AS interacting_percentage
FROM 
    vr_usage;

