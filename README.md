Najczęściej używane komendy Dockera

| Komenda            | Opis                                                                                        |
| ------------------ | ------------------------------------------------------------------------------------------- |
| **`docker build`** | Buduje obraz Dockera na podstawie pliku `Dockerfile`.                                       |
| **`docker run`**   | Uruchamia nowy kontener na podstawie wskazanego obrazu.                                     |
| **`docker pull`**  | Pobiera obraz Dockera z rejestru (np. Docker Hub).                                          |
| **`docker push`**  | Wysyła (publikuje) obraz Dockera do rejestru.                                               |
| **`docker ps`**    | Wyświetla listę **aktualnie działających kontenerów**.                                      |
| **`docker stop`**  | Zatrzymuje działający kontener.                                                             |
| **`docker rm`**    | Usuwa zatrzymany kontener.                                                                  |
| **`docker rmi`**   | Usuwa obraz Dockera.                                                                        |
| **`docker exec`**  | Wykonuje polecenie wewnątrz działającego kontenera (np. `docker exec -it <nazwa> /bin/sh`). |
| **`docker logs`**  | Wyświetla logi (wydruki z konsoli) danego kontenera.                                        |


Najczęściej używane komendy Docker Compose

| Komenda                      | Opis                                                                               |
| ---------------------------- | ---------------------------------------------------------------------------------- |
| **`docker compose up`**      | Tworzy i uruchamia kontenery (buduje obrazy, jeśli to konieczne).                  |
| **`docker compose down`**    | Zatrzymuje i usuwa kontenery, sieci, obrazy oraz wolumeny utworzone przez Compose. |
| **`docker compose start`**   | Uruchamia już istniejące (wcześniej utworzone) kontenery.                          |
| **`docker compose stop`**    | Zatrzymuje działające kontenery bez ich usuwania.                                  |
| **`docker compose restart`** | Restartuje kontenery.                                                              |
| **`docker compose build`**   | Buduje obrazy z plików `Dockerfile` opisanych w `docker-compose.yml`.              |
| **`docker compose ps`**      | Wyświetla listę kontenerów zarządzanych przez `docker-compose`.                    |
| **`docker compose logs`**    | Wyświetla logi wszystkich kontenerów (lub konkretnego, jeśli podasz jego nazwę).   |
| **`docker compose exec`**    | Uruchamia komendę w działającym kontenerze (np. `docker compose exec mariadb sh`). |
| **`docker compose pull`**    | Pobiera obrazy z rejestru (np. jeśli nie chcesz budować ich lokalnie).             |
| **`docker compose push`**    | Wysyła obrazy do rejestru.                                                         |
