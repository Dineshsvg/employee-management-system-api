# Employee Management System API

A RESTful Employee Management System built with **Ruby on Rails 8** and **PostgreSQL**. This project demonstrates backend engineering practices including JWT authentication, role-based access control, REST API development, database relationships, validations, search, pagination, and automated testing.

## Technology Stack

| Technology | Purpose |
|---|---|
| Ruby 3.3.12 | Programming language |
| Ruby on Rails 8.1 | Backend API framework |
| PostgreSQL | Relational database |
| JWT | Token-based authentication |
| BCrypt | Password hashing |
| RSpec | Automated testing |
| Sidekiq / Redis | Background job infrastructure |
| RuboCop | Code quality and style checks |
| Brakeman | Static security analysis |

## Key Features

### Authentication and Authorization
- JWT-based user authentication.
- Secure password handling using BCrypt.
- Token expiration and validation.
- Role-based access control.
- Supports Admin and HR roles.
- Protected API endpoints.

### Employee Management
- Create, retrieve, update, and delete employee records.
- Associate employees with departments.
- Employee data validation.
- Case-insensitive email uniqueness.
- Search employees by name, email, and designation.
- Pagination for employee records.

### Department Management
- Create, retrieve, update, and delete departments.
- Department and employee association.
- Prevent department deletion when employees are associated with it.
- Department name validation and uniqueness.

### Engineering Practices
- RESTful API architecture.
- MVC architecture.
- Active Record associations and validations.
- Consistent JSON error responses.
- Database constraints and relationships.
- RSpec model and request specifications.
- Static code analysis and security scanning.

## Database Design

The application uses PostgreSQL with the following core entities:

- **Users:** Stores user information, credentials, and roles.
- **Departments:** Stores department details.
- **Employees:** Stores employee information and department associations.

### Entity Relationships

```text
User
 ├── id
 ├── name
 ├── email
 ├── password_digest
 └── role

Department
 ├── id
 └── name
      |
      | 1
      |
      | *
Employee
 ├── id
 ├── name
 ├── email
 ├── phone
 ├── designation
 ├── salary
 ├── department_id
 └── user_id (optional)
```

## API Endpoints

Base URL: `/api/v1`

### Authentication

| Method | Endpoint | Description |
|---|---|---|
| POST | `/login` | Authenticate user and generate JWT |

### Employees

| Method | Endpoint | Description |
|---|---|---|
| GET | `/employees` | List employees |
| GET | `/employees/:id` | Retrieve employee details |
| POST | `/employees` | Create employee |
| PATCH | `/employees/:id` | Update employee |
| PUT | `/employees/:id` | Update employee |
| DELETE | `/employees/:id` | Delete employee |

### Departments

| Method | Endpoint | Description |
|---|---|---|
| GET | `/departments` | List departments |
| GET | `/departments/:id` | Retrieve department details |
| POST | `/departments` | Create department |
| PATCH | `/departments/:id` | Update department |
| PUT | `/departments/:id` | Update department |
| DELETE | `/departments/:id` | Delete department |

**Authentication:** Protected endpoints require a valid JWT in the Authorization header.

```http
Authorization: Bearer YOUR_JWT_TOKEN
```

## Getting Started

### Prerequisites

Make sure you have installed:

- Ruby 3.3.12
- Rails 8.1
- PostgreSQL 16
- Bundler

### 1. Clone the repository

```bash
git clone YOUR_GITHUB_REPOSITORY_URL
cd employee_management_system_v2
```

### 2. Install dependencies

```bash
bundle install
```

### 3. Configure environment variables

Create your local environment file:

```bash
cp .env.example .env
```

Configure the required database and application environment variables in `.env`.

Example:

```env
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=your_database_password
JWT_SECRET_KEY=your_secure_secret_key
```

Use your own local credentials and a securely generated JWT secret. Never commit `.env` or production secrets.

### 4. Create and prepare the database

```bash
bin/rails db:create
bin/rails db:migrate
```

### 5. Start the Rails server

```bash
bin/rails server
```

The API will be available at:

```text
http://localhost:3000
```

## Running Tests

This project uses RSpec for automated testing.

Run the complete test suite:

```bash
bundle exec rspec
```

Run individual specifications:

```bash
bundle exec rspec spec/models
bundle exec rspec spec/requests
```

**Current test results:** 72 examples, 0 failures.

## Code Quality and Security

Run RuboCop:

```bash
bundle exec rubocop
```

Run Brakeman:

```bash
bundle exec brakeman -q
```

Run Bundler Audit:

```bash
bundle exec bundler-audit check
```

## Project Structure

```text
app/
 ├── controllers/
 │    └── api/
 │         └── v1/
 ├── models/
 └── ...

config/
db/
spec/
 ├── models/
 └── requests/

.github/
 └── workflows/
      └── ci.yml
```

## Future Enhancements

- API documentation using Swagger / OpenAPI.
- Advanced filtering and sorting.
- Refresh token mechanism.
- Expanded authorization policies.
- Additional integration and performance tests.
- Containerized deployment.

## Role-Based Access Control

The application supports two user roles: **Admin** and **HR**.

All protected API endpoints require JWT-based authentication using a Bearer token.

### Role Permissions

| Operation | Admin | HR |
|---|---|---|
| View dashboard | Yes | Yes |
| View employees | Yes | Yes |
| Create employees | Yes | Yes |
| Update employees | Yes | Yes |
| Delete employees | Yes | No |
| View departments | Yes | Yes |
| Create departments | Yes | No |
| Update departments | Yes | No |
| Delete departments | Yes | No |

### Authorization Rules

- **Admin:** Full access to employee and department management.
- **HR:** Can view, create, and update employee records and view departments.
- Only Admin users can delete employees or create, update, and delete departments.
- Unauthenticated requests are rejected with HTTP `401 Unauthorized`.
- Authenticated users without the required permissions receive HTTP `403 Forbidden`.

## Author

**Dineshbabu V**

Senior / Lead Ruby on Rails Engineer

Ruby on Rails | REST APIs | PostgreSQL | Distributed Systems | Backend Engineering
