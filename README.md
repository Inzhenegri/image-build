# image-build
Репозиторий с кодом для сборки образа для raspberry pi со всеми предустановленными программами. Использовано у клевера.
[CopterExpress/clover](https://github.com/CopterExpress/clover/tree/master/builder)

## Использование
```shell
git clone https://github.com/Inzhenegri/image-build
cd image-build
docker run --privileged -it --rm -v /dev:/dev -v $(pwd):/mnt goldarte/img-tool:v0.5
```
Также можно запустить другие docker команды с этого репозитория [img-tool](https://github.com/goldarte/img-tool)

## travis-ci
travis ci должен автоматически после сбора образа выкладывать его в GitHub Releases

## Что делает скрипт
Скрипт устанавливает все нужные библиотеки, настраивает wifi и создаёт конечный img файл, который потом можно записать на sd карту.