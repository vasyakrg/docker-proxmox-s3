# Практическая работа по развовоту swarm-кластера на Proxmox VE

1. развернем кластер
2. запустим панель управления
3. развернем s3 хранилище с балансировщиком

## Предустановки

1. Само собой, имеем уже настроенный Proxmox VE
2. На локальной машине ставим docker-machine (`brew install docker-machine` - если у вас MacOS)
3. Просаживаем плагин для работы с Proxmox:
   1. качаем от [сюда](https://github.com/lnxbil/docker-machine-driver-proxmox-ve/releases/download/v4/docker-machine-driver-proxmoxve.macos-amd64)
   2. даем права на запуск - `chmod +x docker-machine-driver-proxmoxve.macos-amd64`
   3. перемещаем рабочую папку - `mv docker-machine-driver-proxmoxve.macos-amd64 /usr/local/bin/docker-machine-driver-proxmoxve`
   4. проверяем, что работает плагин `docker-machine create -d proxmoxve --help` (должен появится листинг параметров плагина)
4. качаем образ [докера](https://releases.rancher.com/os/v1.5.1/proxmoxve/rancheros-autoformat.iso) и заливаем его себе в Proxmox

## Использование

1. переименовываем `.env.example` в `.env` и заполняем логопасс от доступа в ваш Proxmox
2. запускаем `swarm-init.sh` - он пробуем цепляться в Proxmox и создает 4 машины (одну мастера и 3 воркера - формально, пока просто 4 пустых машины)
3. идем на мастер `docker-machine ssh docker-master` и запускаем там:
   1. `docker swarm init` - создает мастера и инициализирует рой
   2. `docker swarm join-token worker` - показывает токен, копируем всю строчку в буфер
   3. `exit` - выходим
4. далее, цепляемся к каждому воркеру `docker-machine ssh docker-1` и выполняем команду из буфера
5. после инициализации воркеров и идем снова на мастер `docker-machine ssh docker-master` и проверяем что воркеры подцепились `docker node ls`

## Portainer

1. на мастере запускаем установку стека
   1. `wget https://downloads.portainer.io/portainer-agent-stack.yml --output-document portainer-agent-stack.yml`
   2. `docker stack deploy --compose-file=portainer-agent-stack.yml portainer`
   3. на мастере подсматриваем айпишник `ifconfig eth0` и идем на веб-морду http://ip:9000

## Minio

1. на мастере
   1. создаем секреты (само собой - свои, а не из примера)
      1. `echo "AKIAIOSFODNN7EXAMPLE" | docker secret create access_key -`
      2. `echo "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY" | docker secret create secret_key -`
   2. проставляем метки на воркеры
      1. `docker node update --label-add minio1=true docker-master`
      2. `docker node update --label-add minio2=true docker-2`
      3. `docker node update --label-add minio3=true docker-3`
      4. `docker node update --label-add minio4=true docker-1`
   3. импортируем
   4. в конфиги файлик `lb.conf` и называем его там так же `lb.conf`
   5. запускает новый стек используя код из файла `docker-compose-minio.yaml` и называем стек `minio`
   6. стек поднимет 4 независимые реплики minio со своими дисками на каждой их четырех нод и одну реплику nginx на мастер-ноде, выставит ингресс-линк на порте `8080`
   7. доменное имя для minio выглядит как `minio.local` (можно поменять в lb.conf перед его импортом), не забудьте прописать его у себя в /etc/hosts на айпишники нод (или хотя бы мастер-ноды)


## Чистим за собой
1. `./swarm-rm.sh`

## Видео к курсу
- [видео]()

##### Автор
- **Vassiliy Yegorov** [vasyakrg](https://github.com/vasyakrg)
- [сайт](vk.com/realmanual)
- [youtube](youtube.com/realmanual)
