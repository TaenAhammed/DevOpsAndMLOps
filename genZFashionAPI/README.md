# User CRUD REST API

A simple REST API for managing users with full CRUD operations.

## Setup

```bash
pnpm install
```

## Running the Server

```bash
pnpm start
```

Server runs on `http://localhost:3000`

## Running Tests

```bash
pnpm test
```

## API Endpoints

### Create User
- **POST** `/api/users`
- Body: `{ "name": "John Doe", "email": "john@example.com", "age": 25 }`

### Get All Users
- **GET** `/api/users`

### Get User by ID
- **GET** `/api/users/:id`

### Update User
- **PUT** `/api/users/:id`
- Body: `{ "name": "Jane Doe", "age": 30 }`

### Delete User
- **DELETE** `/api/users/:id`

## User Schema

- `name` (String, required)
- `email` (String, required, unique)
- `age` (Number, optional)
