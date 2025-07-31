-- Grow360: Smart Employee Performance Tracker - Software Company
-- PostgreSQL Compatible with Master Data

-- ============================
-- USER AUTHENTICATION & ROLES
-- ============================

-- System roles for access control
CREATE TABLE system_roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    permissions JSONB NOT NULL, -- Array of permissions
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User accounts for authentication
CREATE TABLE user_accounts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    system_role_id UUID NOT NULL REFERENCES system_roles(id),
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP,
    password_changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================
-- ORGANIZATIONAL STRUCTURE
-- ============================

-- Software company departments
CREATE TABLE departments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    code VARCHAR(10) NOT NULL UNIQUE, -- Dept code like ENG, QA, HR
    description TEXT,
    head_employee_id UUID, -- Will reference employees.id
    budget DECIMAL(15,2),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Software company roles/designations
CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(100) NOT NULL,
    department_id UUID NOT NULL REFERENCES departments(id) ON DELETE CASCADE,
    level VARCHAR(30) NOT NULL,
    grade VARCHAR(10), -- L1, L2, L3, etc.
    min_experience INTEGER, -- Minimum years of experience
    max_experience INTEGER, -- Maximum years of experience
    salary_range_min DECIMAL(12,2),
    salary_range_max DECIMAL(12,2),
    skills_required JSONB, -- Array of required skills
    is_management_role BOOLEAN DEFAULT false,
    reports_to_role_id UUID REFERENCES roles(id), -- Reporting hierarchy
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Software company teams/squads
CREATE TABLE teams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    department_id UUID NOT NULL REFERENCES departments(id),
    team_lead_id UUID, -- Will reference employees.id
    team_type VARCHAR(30) CHECK (team_type IN ('Development', 'QA', 'DevOps', 'Support', 'Research', 'Cross-functional')),
    project_assignment VARCHAR(100),
    max_capacity INTEGER DEFAULT 10,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Employee profiles for software company
CREATE TABLE employees (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id VARCHAR(20) UNIQUE NOT NULL, -- Company employee ID (EMP001, etc.)
    user_account_id UUID UNIQUE REFERENCES user_accounts(id), -- Link to login account
    email VARCHAR(255) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    phone VARCHAR(20),
    date_of_birth DATE,
    hire_date DATE NOT NULL,
    department_id UUID NOT NULL REFERENCES departments(id),
    role_id UUID NOT NULL REFERENCES roles(id),
    team_id UUID REFERENCES teams(id),
    manager_id UUID REFERENCES employees(id), -- Direct reporting manager
    employment_status VARCHAR(20) DEFAULT 'Active' CHECK (employment_status IN ('Active', 'Inactive', 'On Leave', 'Terminated')),
    employee_type VARCHAR(20) DEFAULT 'Full-time' CHECK (employee_type IN ('Full-time', 'Part-time', 'Contract', 'Intern')),
    work_location VARCHAR(50) DEFAULT 'Office' CHECK (work_location IN ('Office', 'Remote', 'Hybrid')),
    current_salary DECIMAL(12,2),
    github_username VARCHAR(50),
    linkedin_profile VARCHAR(255),
    profile_picture_url TEXT,
    address JSONB, -- {street, city, state, country, pincode}
    emergency_contact JSONB, -- {name, phone, relationship}
    joining_bonus DECIMAL(10,2),
    probation_end_date DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Add foreign key constraints
ALTER TABLE departments ADD CONSTRAINT fk_dept_head 
    FOREIGN KEY (head_employee_id) REFERENCES employees(id);

ALTER TABLE teams ADD CONSTRAINT fk_team_lead 
    FOREIGN KEY (team_lead_id) REFERENCES employees(id);

-- Employment history for career progression tracking
CREATE TABLE employment_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    role_id UUID NOT NULL REFERENCES roles(id),
    department_id UUID NOT NULL REFERENCES departments(id),
    team_id UUID REFERENCES teams(id),
    manager_id UUID REFERENCES employees(id),
    start_date DATE NOT NULL,
    end_date DATE, -- NULL for current position
    salary DECIMAL(12,2),
    promotion_type VARCHAR(30) CHECK (promotion_type IN ('Role Change', 'Promotion', 'Transfer', 'Demotion', 'Initial')),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================
-- PROJECTS & TECHNOLOGY STACK
-- ============================

-- Software projects
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(200) NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    description TEXT,
    client_name VARCHAR(100),
    project_manager_id UUID REFERENCES employees(id),
    tech_lead_id UUID REFERENCES employees(id),
    technology_stack JSONB, -- Array of technologies used
    start_date DATE,
    expected_end_date DATE,
    actual_end_date DATE,
    project_status VARCHAR(30) DEFAULT 'Planning' CHECK (project_status IN ('Planning', 'Active', 'On Hold', 'Completed', 'Cancelled')),
    priority VARCHAR(10) DEFAULT 'Medium' CHECK (priority IN ('Low', 'Medium', 'High', 'Critical')),
    budget DECIMAL(15,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Project team assignments
CREATE TABLE project_assignments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
    employee_id UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    role_in_project VARCHAR(50) NOT NULL, -- Developer, Tester, DevOps, etc.
    allocation_percentage DECIMAL(5,2) DEFAULT 100, -- % of time allocated
    start_date DATE NOT NULL,
    end_date DATE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(project_id, employee_id, start_date)
);

-- ============================
-- GOALS & OBJECTIVES (Enhanced for Software Company)
-- ============================

-- Goal categories specific to software development
CREATE TABLE goal_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    category_type VARCHAR(30) CHECK (category_type IN ('Technical', 'Delivery', 'Quality', 'Leadership', 'Learning', 'Process')),
    color_code VARCHAR(7), -- Hex color for UI
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Enhanced goals table for software development
CREATE TABLE goals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    manager_id UUID NOT NULL REFERENCES employees(id), -- Goal setter
    category_id UUID REFERENCES goal_categories(id),
    project_id UUID REFERENCES projects(id), -- Link to specific project
    title VARCHAR(200) NOT NULL,
    description TEXT,
    goal_type VARCHAR(20) DEFAULT 'Quarterly' CHECK (goal_type IN ('Quarterly', 'Annual', 'Project-based', 'Sprint-based')),
    priority VARCHAR(10) DEFAULT 'Medium' CHECK (priority IN ('Low', 'Medium', 'High', 'Critical')),
    weightage DECIMAL(5,2) DEFAULT 20.00 CHECK (weightage >= 0 AND weightage <= 100),
    target_value DECIMAL(15,2), -- Numeric target (code coverage %, story points, etc.)
    current_value DECIMAL(15,2) DEFAULT 0,
    unit VARCHAR(50), -- 'percent', 'story_points', 'bugs_fixed', 'lines_of_code'
    measurement_method TEXT, -- How to measure the goal
    start_date DATE NOT NULL,
    due_date DATE NOT NULL,
    completion_date DATE,
    status VARCHAR(20) DEFAULT 'Not Started' CHECK (status IN ('Not Started', 'In Progress', 'Completed', 'Cancelled', 'On Hold', 'Blocked')),
    progress_percentage DECIMAL(5,2) DEFAULT 0 CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
    is_stretch_goal BOOLEAN DEFAULT false,
    created_by UUID NOT NULL REFERENCES employees(id),
    approved_by UUID REFERENCES employees(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Rest of the schema remains the same as previous version...
-- (Including goal_milestones, goal_progress_logs, review_cycles, etc.)

-- ============================
-- MASTER DATA INSERTS
-- ============================

-- Insert System Roles
INSERT INTO system_roles (role_name, description, permissions) VALUES
('super_admin', 'Super Administrator with full access', '["all"]'::jsonb),
('hr_admin', 'HR Administrator', '["view_all_employees", "manage_reviews", "manage_goals", "view_reports", "manage_departments"]'::jsonb),
('manager', 'Team Manager', '["view_team_employees", "manage_team_goals", "conduct_reviews", "view_team_reports"]'::jsonb),
('employee', 'Regular Employee', '["view_own_data", "update_own_goals", "submit_reviews", "view_own_reports"]'::jsonb),
('project_manager', 'Project Manager', '["view_project_team", "manage_project_goals", "view_project_reports"]'::jsonb);

-- Insert Departments
INSERT INTO departments (name, code, description) VALUES
('Engineering', 'ENG', 'Software Development and Engineering'),
('Quality Assurance', 'QA', 'Quality Assurance and Testing'),
('DevOps & Infrastructure', 'DEVOPS', 'DevOps, Infrastructure and Site Reliability'),
('Product Management', 'PM', 'Product Management and Strategy'),
('User Experience', 'UX', 'UI/UX Design and User Research'),
('Data & Analytics', 'DATA', 'Data Science and Analytics'),
('Human Resources', 'HR', 'Human Resources and People Operations'),
('Sales & Marketing', 'SALES', 'Sales, Marketing and Business Development'),
('Finance & Operations', 'FIN', 'Finance, Operations and Administration'),
('Research & Development', 'RND', 'Research and Development'),
('Customer Success', 'CS', 'Customer Success and Support');

-- Insert Roles for Engineering Department
INSERT INTO roles (title, department_id, level, grade, min_experience, max_experience, salary_range_min, salary_range_max, is_management_role, skills_required) VALUES
-- Engineering Roles
('Software Engineer Intern', (SELECT id FROM departments WHERE code = 'ENG'), 'Intern', 'L0', 0, 1, 20000, 35000, false, '["Programming Basics", "Git", "Problem Solving"]'::jsonb),
('Junior Software Engineer', (SELECT id FROM departments WHERE code = 'ENG'), 'Junior', 'L1', 0, 2, 400000, 800000, false, '["Java/Python/JavaScript", "Git", "Databases", "Problem Solving"]'::jsonb),
('Software Engineer', (SELECT id FROM departments WHERE code = 'ENG'), 'Mid-Level', 'L2', 2, 4, 800000, 1400000, false, '["Full Stack Development", "System Design", "Testing", "Agile"]'::jsonb),
('Senior Software Engineer', (SELECT id FROM departments WHERE code = 'ENG'), 'Senior', 'L3', 4, 7, 1400000, 2200000, false, '["Advanced Programming", "Architecture", "Mentoring", "Code Review"]'::jsonb),
('Lead Software Engineer', (SELECT id FROM departments WHERE code = 'ENG'), 'Lead', 'L4', 6, 10, 2000000, 3000000, true, '["Technical Leadership", "Architecture", "Team Management"]'::jsonb),
('Principal Engineer', (SELECT id FROM departments WHERE code = 'ENG'), 'Principal', 'L5', 8, 15, 2800000, 4500000, true, '["System Architecture", "Strategic Thinking", "Cross-team Collaboration"]'::jsonb),
('Engineering Manager', (SELECT id FROM departments WHERE code = 'ENG'), 'Manager', 'M1', 5, 12, 2500000, 4000000, true, '["People Management", "Technical Strategy", "Delivery Management"]'::jsonb),
('Senior Engineering Manager', (SELECT id FROM departments WHERE code = 'ENG'), 'Senior Manager', 'M2', 8, 15, 3500000, 5500000, true, '["Strategic Leadership", "Cross-functional Collaboration", "Budget Management"]'::jsonb),
('Director of Engineering', (SELECT id FROM departments WHERE code = 'ENG'), 'Director', 'D1', 12, 20, 5000000, 8000000, true, '["Executive Leadership", "Strategic Planning", "Organizational Development"]'::jsonb),

-- QA Roles
('QA Intern', (SELECT id FROM departments WHERE code = 'QA'), 'Intern', 'L0', 0, 1, 18000, 30000, false, '["Manual Testing", "Bug Reporting", "Test Cases"]'::jsonb),
('Junior QA Engineer', (SELECT id FROM departments WHERE code = 'QA'), 'Junior', 'L1', 0, 2, 350000, 700000, false, '["Manual Testing", "Automation Basics", "SQL"]'::jsonb),
('QA Engineer', (SELECT id FROM departments WHERE code = 'QA'), 'Mid-Level', 'L2', 2, 4, 700000, 1200000, false, '["Test Automation", "API Testing", "Performance Testing"]'::jsonb),
('Senior QA Engineer', (SELECT id FROM departments WHERE code = 'QA'), 'Senior', 'L3', 4, 7, 1200000, 2000000, false, '["Test Strategy", "Framework Development", "Mentoring"]'::jsonb),
('QA Lead', (SELECT id FROM departments WHERE code = 'QA'), 'Lead', 'L4', 5, 10, 1800000, 2800000, true, '["Team Leadership", "Quality Strategy", "Process Improvement"]'::jsonb),
('QA Manager', (SELECT id FROM departments WHERE code = 'QA'), 'Manager', 'M1', 6, 12, 2200000, 3500000, true, '["People Management", "Quality Assurance Strategy"]'::jsonb),

-- DevOps Roles
('DevOps Engineer', (SELECT id FROM departments WHERE code = 'DEVOPS'), 'Mid-Level', 'L2', 2, 4, 900000, 1500000, false, '["AWS/Azure", "Docker", "Kubernetes", "CI/CD"]'::jsonb),
('Senior DevOps Engineer', (SELECT id FROM departments WHERE code = 'DEVOPS'), 'Senior', 'L3', 4, 7, 1500000, 2500000, false, '["Infrastructure as Code", "Monitoring", "Security"]'::jsonb),
('DevOps Lead', (SELECT id FROM departments WHERE code = 'DEVOPS'), 'Lead', 'L4', 5, 10, 2200000, 3200000, true, '["Infrastructure Strategy", "Team Leadership"]'::jsonb),
('Site Reliability Engineer', (SELECT id FROM departments WHERE code = 'DEVOPS'), 'Senior', 'L3', 3, 6, 1600000, 2600000, false, '["System Reliability", "Incident Management", "Automation"]'::jsonb),

-- Product Management Roles
('Associate Product Manager', (SELECT id FROM departments WHERE code = 'PM'), 'Junior', 'L1', 0, 2, 800000, 1200000, false, '["Product Strategy", "Market Analysis", "Stakeholder Management"]'::jsonb),
('Product Manager', (SELECT id FROM departments WHERE code = 'PM'), 'Mid-Level', 'L2', 2, 5, 1200000, 2000000, false, '["Product Roadmap", "User Research", "Analytics"]'::jsonb),
('Senior Product Manager', (SELECT id FROM departments WHERE code = 'PM'), 'Senior', 'L3', 4, 8, 2000000, 3200000, false, '["Strategic Planning", "Cross-functional Leadership"]'::jsonb),
('Principal Product Manager', (SELECT id FROM departments WHERE code = 'PM'), 'Principal', 'L4', 6, 12, 2800000, 4500000, true, '["Product Strategy", "Vision Setting", "Executive Communication"]'::jsonb),

-- UX Roles
('UI/UX Designer', (SELECT id FROM departments WHERE code = 'UX'), 'Mid-Level', 'L2', 1, 4, 600000, 1200000, false, '["Figma", "User Research", "Prototyping", "Design Systems"]'::jsonb),
('Senior UI/UX Designer', (SELECT id FROM departments WHERE code = 'UX'), 'Senior', 'L3', 3, 6, 1200000, 2000000, false, '["Design Leadership", "User Experience Strategy"]'::jsonb),
('Design Lead', (SELECT id FROM departments WHERE code = 'UX'), 'Lead', 'L4', 5, 10, 1800000, 2800000, true, '["Design Strategy", "Team Management", "Design Systems"]'::jsonb),

-- Data & Analytics Roles
('Data Analyst', (SELECT id FROM departments WHERE code = 'DATA'), 'Mid-Level', 'L2', 1, 3, 700000, 1300000, false, '["SQL", "Python/R", "Data Visualization", "Statistics"]'::jsonb),
('Data Scientist', (SELECT id FROM departments WHERE code = 'DATA'), 'Senior', 'L3', 2, 5, 1300000, 2200000, false, '["Machine Learning", "Statistical Modeling", "Python"]'::jsonb),
('Senior Data Scientist', (SELECT id FROM departments WHERE code = 'DATA'), 'Senior', 'L4', 4, 8, 2000000, 3200000, false, '["Advanced ML", "Model Deployment", "Mentoring"]'::jsonb),
('Data Engineering Manager', (SELECT id FROM departments WHERE code = 'DATA'), 'Manager', 'M1', 5, 10, 2500000, 4000000, true, '["Data Strategy", "Team Leadership", "Big Data Technologies"]'::jsonb),

-- HR Roles
('HR Executive', (SELECT id FROM departments WHERE code = 'HR'), 'Junior', 'L1', 0, 2, 400000, 700000, false, '["Recruitment", "Employee Relations", "HR Operations"]'::jsonb),
('HR Business Partner', (SELECT id FROM departments WHERE code = 'HR'), 'Mid-Level', 'L2', 2, 5, 800000, 1400000, false, '["Strategic HR", "Performance Management", "Organization Development"]'::jsonb),
('Senior HR Business Partner', (SELECT id FROM departments WHERE code = 'HR'), 'Senior', 'L3', 4, 8, 1400000, 2200000, false, '["HR Strategy", "Change Management", "Leadership Development"]'::jsonb),
('HR Manager', (SELECT id FROM departments WHERE code = 'HR'), 'Manager', 'M1', 5, 10, 1800000, 2800000, true, '["People Strategy", "Team Management", "Policy Development"]'::jsonb),
('Director of People Operations', (SELECT id FROM departments WHERE code = 'HR'), 'Director', 'D1', 8, 15, 3000000, 5000000, true, '["Strategic HR Leadership", "Organizational Development"]'::jsonb);

-- Insert Teams
INSERT INTO teams (name, department_id, team_type, max_capacity) VALUES
('Frontend Platform Team', (SELECT id FROM departments WHERE code = 'ENG'), 'Development', 8),
('Backend Services Team', (SELECT id FROM departments WHERE code = 'ENG'), 'Development', 10),
('Mobile Development Team', (SELECT id FROM departments WHERE code = 'ENG'), 'Development', 6),
('DevOps & Infrastructure', (SELECT id FROM departments WHERE code = 'DEVOPS'), 'DevOps', 5),
('Quality Engineering', (SELECT id FROM departments WHERE code = 'QA'), 'QA', 8),
('Data Platform Team', (SELECT id FROM departments WHERE code = 'DATA'), 'Development', 6),
('Product Strategy', (SELECT id FROM departments WHERE code = 'PM'), 'Cross-functional', 4),
('Design System Team', (SELECT id FROM departments WHERE code = 'UX'), 'Development', 4),
('People Operations', (SELECT id FROM departments WHERE code = 'HR'), 'Support', 6);

-- Insert Sample Employees with Hierarchy
INSERT INTO employees (employee_id, email, first_name, last_name, hire_date, department_id, role_id, team_id, manager_id, current_salary, work_location) VALUES
-- CEO/CTO Level
('EMP001', 'john.doe@company.com', 'John', 'Doe', '2020-01-15', (SELECT id FROM departments WHERE code = 'ENG'), (SELECT id FROM roles WHERE title = 'Director of Engineering'), NULL, NULL, 6000000, 'Office'),

-- Engineering Managers
('EMP002', 'sarah.wilson@company.com', 'Sarah', 'Wilson', '2020-03-20', (SELECT id FROM departments WHERE code = 'ENG'), (SELECT id FROM roles WHERE title = 'Engineering Manager'), (SELECT id FROM teams WHERE name = 'Frontend Platform Team'), (SELECT id FROM employees WHERE employee_id = 'EMP001'), 3200000, 'Hybrid'),
('EMP003', 'mike.johnson@company.com', 'Mike', 'Johnson', '2020-05-10', (SELECT id FROM departments WHERE code = 'ENG'), (SELECT id FROM roles WHERE title = 'Engineering Manager'), (SELECT id FROM teams WHERE name = 'Backend Services Team'), (SELECT id FROM employees WHERE employee_id = 'EMP001'), 3400000, 'Office'),

-- Senior Engineers
('EMP004', 'priya.sharma@company.com', 'Priya', 'Sharma', '2021-02-15', (SELECT id FROM departments WHERE code = 'ENG'), (SELECT id FROM roles WHERE title = 'Senior Software Engineer'), (SELECT id FROM teams WHERE name = 'Frontend Platform Team'), (SELECT id FROM employees WHERE employee_id = 'EMP002'), 1800000, 'Remote'),
('EMP005', 'alex.chen@company.com', 'Alex', 'Chen', '2021-04-12', (SELECT id FROM departments WHERE code = 'ENG'), (SELECT id FROM roles WHERE title = 'Lead Software Engineer'), (SELECT id FROM teams WHERE name = 'Backend Services Team'), (SELECT id FROM employees WHERE employee_id = 'EMP003'), 2400000, 'Hybrid'),

-- Mid-level Engineers
('EMP006', 'raj.patel@company.com', 'Raj', 'Patel', '2022-01-20', (SELECT id FROM departments WHERE code = 'ENG'), (SELECT id FROM roles WHERE title = 'Software Engineer'), (SELECT id FROM teams WHERE name = 'Frontend Platform Team'), (SELECT id FROM employees WHERE employee_id = 'EMP002'), 1100000, 'Office'),
('EMP007', 'emily.davis@company.com', 'Emily', 'Davis', '2022-03-15', (SELECT id FROM departments WHERE code = 'ENG'), (SELECT id FROM roles WHERE title = 'Software Engineer'), (SELECT id FROM teams WHERE name = 'Backend Services Team'), (SELECT id FROM employees WHERE employee_id = 'EMP003'), 1200000, 'Remote'),

-- Junior Engineers
('EMP008', 'david.kumar@company.com', 'David', 'Kumar', '2023-06-01', (SELECT id FROM departments WHERE code = 'ENG'), (SELECT id FROM roles WHERE title = 'Junior Software Engineer'), (SELECT id FROM teams WHERE name = 'Frontend Platform Team'), (SELECT id FROM employees WHERE employee_id = 'EMP004'), 650000, 'Hybrid'),
('EMP009', 'lisa.wong@company.com', 'Lisa', 'Wong', '2023-07-15', (SELECT id FROM departments WHERE code = 'ENG'), (SELECT id FROM roles WHERE title = 'Junior Software Engineer'), (SELECT id FROM teams WHERE name = 'Backend Services Team'), (SELECT id FROM employees WHERE employee_id = 'EMP005'), 700000, 'Office'),

-- QA Team
('EMP010', 'james.taylor@company.com', 'James', 'Taylor', '2021-08-20', (SELECT id FROM departments WHERE code = 'QA'), (SELECT id FROM roles WHERE title = 'QA Manager'), (SELECT id FROM teams WHERE name = 'Quality Engineering'), (SELECT id FROM employees WHERE employee_id = 'EMP001'), 2800000, 'Office'),
('EMP011', 'anna.garcia@company.com', 'Anna', 'Garcia', '2022-02-10', (SELECT id FROM departments WHERE code = 'QA'), (SELECT id FROM roles WHERE title = 'Senior QA Engineer'), (SELECT id FROM teams WHERE name = 'Quality Engineering'), (SELECT id FROM employees WHERE employee_id = 'EMP010'), 1600000, 'Hybrid'),
('EMP012', 'tom.brown@company.com', 'Tom', 'Brown', '2023-01-25', (SELECT id FROM departments WHERE code = 'QA'), (SELECT id FROM roles WHERE title = 'QA Engineer'), (SELECT id FROM teams WHERE name = 'Quality Engineering'), (SELECT id FROM employees WHERE employee_id = 'EMP010'), 950000, 'Remote'),

-- DevOps Team
('EMP013', 'maria.rodriguez@company.com', 'Maria', 'Rodriguez', '2021-06-15', (SELECT id FROM departments WHERE code = 'DEVOPS'), (SELECT id FROM roles WHERE title = 'DevOps Lead'), (SELECT id FROM teams WHERE name = 'DevOps & Infrastructure'), (SELECT id FROM employees WHERE employee_id = 'EMP001'), 2800000, 'Office'),
('EMP014', 'chris.lee@company.com', 'Chris', 'Lee', '2022-09-10', (SELECT id FROM departments WHERE code = 'DEVOPS'), (SELECT id FROM roles WHERE title = 'Senior DevOps Engineer'), (SELECT id FROM teams WHERE name = 'DevOps & Infrastructure'), (SELECT id FROM employees WHERE employee_id = 'EMP013'), 2100000, 'Hybrid'),

-- HR Team
('EMP015', 'jennifer.smith@company.com', 'Jennifer', 'Smith', '2020-08-01', (SELECT id FROM departments WHERE code = 'HR'), (SELECT id FROM roles WHERE title = 'Director of People Operations'), (SELECT id FROM teams WHERE name = 'People Operations'), NULL, 4200000, 'Office'),
('EMP016', 'robert.jones@company.com', 'Robert', 'Jones', '2021-11-20', (SELECT id FROM departments WHERE code = 'HR'), (SELECT id FROM roles WHERE title = 'Senior HR Business Partner'), (SELECT id FROM teams WHERE name = 'People Operations'), (SELECT id FROM employees WHERE employee_id = 'EMP015'), 1800000, 'Office');

-- Update team leads
UPDATE teams SET team_lead_id = (SELECT id FROM employees WHERE employee_id = 'EMP002') WHERE name = 'Frontend Platform Team';
UPDATE teams SET team_lead_id = (SELECT id FROM employees WHERE employee_id = 'EMP003') WHERE name = 'Backend Services Team';
UPDATE teams SET team_lead_id = (SELECT id FROM employees WHERE employee_id = 'EMP010') WHERE name = 'Quality Engineering';
UPDATE teams SET team_lead_id = (SELECT id FROM employees WHERE employee_id = 'EMP013') WHERE name = 'DevOps & Infrastructure';
UPDATE teams SET team_lead_id = (SELECT id FROM employees WHERE employee_id = 'EMP015') WHERE name = 'People Operations';

-- Update department heads
UPDATE departments SET head_employee_id = (SELECT id FROM employees WHERE employee_id = 'EMP001') WHERE code = 'ENG';
UPDATE departments SET head_employee_id = (SELECT id FROM employees WHERE employee_id = 'EMP010') WHERE code = 'QA';
UPDATE departments SET head_employee_id = (SELECT id FROM employees WHERE employee_id = 'EMP013') WHERE code = 'DEVOPS';
UPDATE departments SET head_employee_id = (SELECT id FROM employees WHERE employee_id = 'EMP015') WHERE code = 'HR';

-- Insert Sample User Accounts
INSERT INTO user_accounts (username, email, password_hash, system_role_id) VALUES
-- Management accounts
('john.doe', 'john.doe@company.com', '$2b$12$hash_for_john', (SELECT id FROM system_roles WHERE role_name = 'super_admin')),
('sarah.wilson', 'sarah.wilson@company.com', '$2b$12$hash_for_sarah', (SELECT id FROM system_roles WHERE role_name = 'manager')),
('mike.johnson', 'mike.johnson@company.com', '$2b$12$hash_for_mike', (SELECT id FROM system_roles WHERE role_name = 'manager')),
('james.taylor', 'james.taylor@company.com', '$2b$12$hash_for_james', (SELECT id FROM system_roles WHERE role_name = 'manager')),
('maria.rodriguez', 'maria.rodriguez@company.com', '$2b$12$hash_for_maria', (SELECT id FROM system_roles WHERE role_name = 'manager')),
('jennifer.smith', 'jennifer.smith@company.com', '$2b$12$hash_for_jennifer', (SELECT id FROM system_roles WHERE role_name = 'hr_admin')),

-- Employee accounts
('priya.sharma', 'priya.sharma@company.com', '$2b$12$hash_for_priya', (SELECT id FROM system_roles WHERE role_name = 'employee')),
('alex.chen', 'alex.chen@company.com', '$2b$12$hash_for_alex', (SELECT id FROM system_roles WHERE role_name = 'employee')),
('raj.patel', 'raj.patel@company.com', '$2b$12$hash_for_raj', (SELECT id FROM system_roles WHERE role_name = 'employee')),
('emily.davis', 'emily.davis@company.com', '$2b$12$