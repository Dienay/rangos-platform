#!/usr/bin/env bash

# ==========================================================
# Rangos Platform - Development Helper
# ==========================================================

set -e

API_SERVICE="backend"

show_help() {
  cat <<EOF

Rangos Platform - Development Helper

Usage:
  ./run.sh <command>

Docker
  up                Start the application
  build             Build Docker images
  rebuild           Rebuild and start
  rebuild:force     Force recreate containers
  down              Stop and remove containers
  stop              Stop containers
  restart           Restart containers
  logs [service]    Show logs
  ps                List containers

Development
  shell             Open shell inside backend container
  test              Run all tests
  test:cov          Run tests with coverage
  lint              Run Ruff linter
  format            Format code with Ruff
  migrate           Run Alembic migrations
  makemigration     Create a new Alembic migration

Maintenance
  clean             Remove containers, local images and volumes
  clean:all         Remove everything (including pulled images)
  purge             Full cleanup (asks for confirmation)

EOF
}

# Verifica se um comando foi fornecido
if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

COMMAND=$1
shift

docker-compose() {
    docker compose "$@"
}

resolve_project_name() {
    PROJECT_NAME=$(docker compose config 2>/dev/null | awk '/^name:/{print $2; exit}')

    if [ -z "$PROJECT_NAME" ]; then
        echo "Could not determine compose project name."
        exit 1
    fi
}

clean_dangling_by_label() {
    local filter="label=com.docker.compose.project=${PROJECT_NAME}"

    docker volume prune -f --filter "$filter" || true
    docker image prune -f --filter "$filter" || true
    docker network prune -f --filter "$filter" || true
}

purge_everything_by_label() {
    local filter="label=com.docker.compose.project=${PROJECT_NAME}"

    containers=$(docker ps -aq --filter "$filter")
    [ -n "$containers" ] && docker rm -f $containers

    images=$(docker images -q --filter "$filter")
    [ -n "$images" ] && docker rmi -f $images || true

    docker builder prune -f --filter "$filter" || true
}

case $COMMAND in
    up)
      docker-compose up
    ;;
    build)
      docker-compose build
    ;;
    rebuild)
      docker-compose up --build
    ;;
    rebuild:force)
      docker-compose up --build --force-recreate
    ;;
    down)
      docker-compose down
    ;;
    logs)
      docker-compose logs -f "$@"
    ;;
    stop)
      docker-compose stop
    ;;
    restart)
      docker-compose restart
    ;;
    ps)
      docker-compose ps
    ;;
    shell)
      docker-compose exec "$API_SERVICE" bash
    ;;
    test)
      docker-compose exec "$API_SERVICE" pytest
    ;;
    test:cov)
      docker-compose exec "$API_SERVICE" pytest --cov=app --cov-report=term-missing
    ;;
    lint)
      docker-compose exec "$API_SERVICE" ruff check .
    ;;
    format)
      docker-compose exec "$API_SERVICE" ruff check --fix .
      docker-compose exec "$API_SERVICE" ruff format .
    ;;
    migrate)
      docker-compose exec "$API_SERVICE" alembic upgrade head
    ;;
    makemigrations)
      docker-compose exec "$API_SERVICE" alembic revision --autogenerate -m "$*"
    ;;
    clean)
      resolve_project_name
      docker-compose down -v --remove-orphans --rmi local
      clean_dangling_by_label
    ;;
    clean:all)
      resolve_project_name
      docker-compose down -v --remove-orphans --rmi all
      clean_dangling_by_label
    ;;
    purge)
      resolve_project_name

      echo ""
      echo "This will completely remove:"
      echo " - Containers"
      echo " - Networks"
      echo " - Volumes"
      echo " - Images"
      echo " - Build cache"
      echo ""

      read -p "Continue? [y/N] " confirm

      if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
          echo "Cancelled."
          exit 0
      fi

      docker-compose down -v --remove-orphans --rmi all || true
      clean_dangling_by_label
      purge_everything_by_label
    ;;
    *)
        show_help
        exit 1
        ;;
esac
# Comando	                  Faz
# run up	                  sobe a aplicação
# run down	                derruba
# run logs	                logs
# run shell	                entra no container
# run test	                pytest
# run test:unit	            somente unitários
# run test:integration	    somente integração
# run test:contract	        Schemathesis
# run test:e2e	            Playwright
# run lint	                Ruff
# run format	              Ruff format
# run migrate	              Alembic upgrade
# run makemigration	        cria migration
# run db:reset	            recria banco de desenvolvimento
# run seed	                popula banco de demonstração
# run docs	                abre Swagger
# run coverage	            gera relatório HTML
