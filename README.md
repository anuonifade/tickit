# HIPAA-Compliant Mental Health Survey Application

A secure, HIPAA-compliant mental health survey application built with Ruby on Rails API backend and React/TypeScript frontend. This application is designed to collect mental health survey data while ensuring HIPAA compliance and data security. It can be deployed using Docker for local development or Kubernetes for production environments.

## Features

- Secure survey submission with data encryption
- HIPAA-compliant data storage and handling
- Analytics dashboard for aggregated survey data
- Comprehensive validation and error handling
- Responsive UI design
- Kubernetes-ready deployment configuration
- Health check endpoints for container orchestration
- Cross-Origin Resource Sharing (CORS) configured for secure communication

## Technology Stack

### Backend (Rails API)
- Ruby 3.x
- Rails 7.0.8
- PostgreSQL
- Lockbox for encryption
- Blind Index for searchable encrypted fields
- RSpec for testing

### Frontend (React)
- React 18
- TypeScript
- Material UI
- Formik for form handling
- Axios for API requests

## Setup Instructions

### Option 1: Using Docker (Recommended)

#### Prerequisites
- Docker
- Docker Compose

#### Setup Steps

1. Generate secure keys for HIPAA compliance:
   ```bash
   ./generate_keys.sh
   ```

2. Start the application using Docker Compose:
   ```bash
   docker compose up
   ```

3. The application will be available at:
   - Frontend: http://localhost:80
   - API: http://localhost:3000/api/v1

#### Development Workflow with Docker

- View logs:
   ```bash
   docker compose logs -f
   ```

- Run Rails commands:
   ```bash
   docker compose exec api bundle exec rails console
   docker compose exec api bundle exec rails db:migrate
   ```

- Run frontend commands:
   ```bash
   docker compose exec frontend npm test
   ```

### Option 2: Manual Setup

#### Prerequisites
- Ruby 3.x
- Node.js 16+
- PostgreSQL
- Yarn or npm

#### Backend Setup

1. Navigate to the API directory:
   ```bash
   cd tickit-api
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

3. Set up the database:
   ```bash
   rails db:create db:migrate db:seed
   ```

4. Set up encryption keys (in development):
   ```bash
   rails console
   # In the console, run:
   puts SecureRandom.hex(32) # For LOCKBOX_MASTER_KEY
   puts SecureRandom.hex(32) # For BLIND_INDEX_MASTER_KEY
   exit
   ```

5. Create a `.env` file in the `tickit-api` directory with the generated keys:
   ```
   LOCKBOX_MASTER_KEY=your_generated_key_here
   BLIND_INDEX_MASTER_KEY=your_generated_key_here
   ```

6. Start the Rails server:
   ```bash
   rails server
   ```

#### Frontend Setup

1. Navigate to the frontend directory:
   ```bash
   cd tickit-app/frontend
   ```

2. Install dependencies:
   ```bash
   yarn install
   # or
   npm install
   ```

3. Start the development server:
   ```bash
   yarn start
   # or
   npm start
   ```

4. The application will be available at `http://localhost:3000`

## API Endpoints

### Survey Submission
- **POST** `/api/v1/surveys`
  - Creates a new survey response
  - Required fields: `feeling`, `stress_level`, `sleep_hours`, `symptoms`

### Analytics
- **GET** `/api/v1/surveys/analytics`
  - Returns aggregated survey data
  - Includes average scores and response count

## HIPAA Compliance Features

- All sensitive health data is encrypted at rest using AES-GCM via the Lockbox gem
- Blind indexing allows for secure searching of encrypted data
- No personally identifiable information is stored
- All data transmission is secured through our Docker setup with Nginx
- Network segregation in Docker (frontend and backend networks) for added security
- Comprehensive audit logging
- Strict access controls

### Docker Security Measures

- Isolated network segments (frontend and backend networks)
- Secure environment variable management
- Container restart policies to ensure availability
- Volume management for persistent, secure data storage
- Health checks to ensure service availability
- Nginx configured with security headers
- Separate build and runtime stages for minimal attack surface

## Testing

### Backend Tests
```
cd tickit-api
bundle exec rspec
```

### Frontend Tests
```
cd tickit-app/frontend
yarn test
# or
npm test
```

## Kubernetes Deployment

This application is designed to be deployed to a Kubernetes cluster for production environments.

### Prerequisites

- Kubernetes cluster (e.g., GKE, EKS, AKS, or Minikube for local testing)
- kubectl CLI configured to access your cluster
- Docker registry access (e.g., Docker Hub, GCR, ECR)

### Deployment Steps

1. **Build and push Docker images**

   ```bash
   # Build and push the Rails API image
   docker build -t your-registry/tickit-api:latest ./tickit-api
   docker push your-registry/tickit-api:latest
   
   # Build and push the React frontend image
   docker build -t your-registry/tickit-frontend:latest ./tickit-app/frontend
   docker push your-registry/tickit-frontend:latest
   ```

2. **Update image references in Kubernetes manifests**

   Edit the `k8s/rails-deployment.yaml` and `k8s/frontend-deployment.yaml` files to use your image references.

3. **Create a namespace for the application**

   ```bash
   kubectl create namespace tickit-prod
   ```

4. **Create Kubernetes secrets for sensitive data**

   ```bash
   kubectl create secret generic db-credentials \
     --from-literal=POSTGRES_USER=postgres \
     --from-literal=POSTGRES_PASSWORD=your-secure-password \
     --from-literal=POSTGRES_DB=tickit_production \
     --namespace tickit-prod
   
   kubectl create secret generic rails-secrets \
     --from-literal=LOCKBOX_MASTER_KEY=$(openssl rand -hex 32) \
     --from-literal=BLIND_INDEX_MASTER_KEY=$(openssl rand -hex 32) \
     --from-literal=SECRET_KEY_BASE=$(openssl rand -hex 64) \
     --namespace tickit-prod
   ```

5. **Deploy the PostgreSQL database**

   ```bash
   kubectl apply -f k8s/postgres-deployment.yaml -n tickit-prod
   ```

6. **Deploy the Rails API**

   ```bash
   kubectl apply -f k8s/rails-deployment.yaml -n tickit-prod
   ```

7. **Deploy the React frontend**

   ```bash
   kubectl apply -f k8s/frontend-deployment.yaml -n tickit-prod
   ```

8. **Verify the deployment**

   ```bash
   kubectl get pods -n tickit-prod
   kubectl get services -n tickit-prod
   ```

9. **Access the application**

   For local testing with Minikube:
   ```bash
   # For the frontend
   kubectl port-forward svc/react-frontend 8080:80 -n tickit-prod
   # For the API
   kubectl port-forward svc/rails-api 3000:3000 -n tickit-prod
   ```

   For cloud deployments, configure an Ingress or LoadBalancer service.

### Kubernetes Manifests

The `k8s` directory contains all necessary Kubernetes manifests:

- `postgres-deployment.yaml`: PostgreSQL database deployment and service
- `rails-deployment.yaml`: Rails API deployment and service
- `frontend-deployment.yaml`: React frontend deployment and service

## Component Documentation

For more detailed information about each component, refer to their individual README files:

- [Rails API Documentation](./tickit-api/README.md): Details about the Rails API, including endpoints, HIPAA compliance measures, and database configuration.
- [React Frontend Documentation](./tickit-app/frontend/README.md): Information about the React frontend, including component structure, state management, and UI design.

## Security Considerations

- In production, ensure all environment variables are securely stored using Kubernetes secrets
- Use HTTPS for all API communications, preferably with a properly configured Ingress controller
- Implement proper authentication and authorization with JWT tokens
- Regularly audit and update dependencies
- Run security scanners like Brakeman regularly
- Consider implementing network policies in Kubernetes for additional security
- Use Pod Security Policies or Pod Security Standards to restrict container privileges
