# image-build
Репозиторий с кодом для сборки образа для raspberry pi со всеми предустановленными программами.

## Использование
```shell
git clone https://github.com/Inzhenegri/image-build
cd image-build
docker run --privileged -it --rm -v /dev:/dev -v $(pwd):/mnt goldarte/img-tool:v0.5
```

## travis-ci
travis ci должен автоматически после сбора образа выкладывать его в GitHub Releases

## Что делает скрипт
Скрипт устанавливает все нужные библиотеки, настраивает wifi и создаёт конечный img файл, который потом можно записать на sd карту.
