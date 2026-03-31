# Simple Notes App

A full-stack notes application built with Django REST Framework and React, containerized with Docker and deployed to AWS ECS Fargate.

## Tech Stack

**Backend:** Django REST Framework, Python 3.11, Gunicorn, PostgreSQL  
**Frontend:** React, Vite, Axios  
**Infrastructure:** Docker, AWS ECS Fargate, AWS ECR, AWS RDS, AWS S3, AWS CloudFront, AWS ALB

---

## Architecture

```
Browser
   ↓
CloudFront (HTTPS)
   ├── /* → S3 (React frontend)
   └── /api/* → ALB → ECS Fargate (Django API)
                              ↓
                        PostgreSQL (RDS)
```

- The React frontend is hosted on S3 and distributed via CloudFront over HTTPS
- All API traffic routes through CloudFront to the ALB and into the Django container
- The ALB security group restricts inbound traffic to CloudFront IP ranges only using the AWS-managed prefix list — direct ALB access is blocked
- The Django backend runs as a containerized service on ECS Fargate
- The Docker image is stored in ECR and pulled by ECS at deploy time
- PostgreSQL runs on RDS in a private subnet, only accessible by the backend

---

## Security

- **CloudFront-only ALB access** — The ALB security group uses the AWS-managed CloudFront prefix list (`com.amazonaws.global.cloudfront.origin-facing`) to block all traffic not originating from CloudFront
- **JWT authentication** — All API endpoints require a valid JWT token except registration and login
- **Environment variables** — Secrets and configuration are passed via ECS task definition environment variables, never hardcoded
- **Private RDS** — The database runs in a private subnet with no public access

---

## Local Development

### Prerequisites

- Docker and Docker Compose
- Python 3.11
- Node.js

### Backend

Create a `.env` file in the `backend` folder:

```
SECRET_KEY=your-secret-key
DEBUG=True
DB_HOST=db
DB_NAME=notes_db
DB_USER=notes_user
DB_PASSWORD=notes_pass
DB_PORT=5432
```

Start the backend and database:

```bash
cd backend
docker compose up --build
```

Migrations run automatically on startup.

### Frontend

Create a `.env` file in the `frontend` folder:

```
VITE_API_URL=http://localhost:8000
```

Then run:

```bash
cd frontend
npm install
npm run dev
```

---

## Deployment

The app is deployed to AWS using the following services:

- **ECR** — stores the Docker image
- **ECS Fargate** — runs the containerized Django backend
- **RDS** — managed PostgreSQL database
- **S3** — hosts the built React frontend
- **CloudFront** — CDN and HTTPS termination for both frontend and backend API
- **ALB** — load balancer in front of ECS, restricted to CloudFront traffic only

Migrations run automatically when the ECS task starts via `entrypoint.sh`.

---

## Future Considerations

- **Custom domain** — add a custom domain with an ACM certificate
- **CI/CD** — automate image builds and deployments via GitHub Actions
- **WAF** — add AWS WAF for Layer 7 DDoS protection
- **Environment separation** — separate staging and production environments
- **App features** — add note categories, tags, search, and sharing functionality
