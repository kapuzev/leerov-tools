# leerov-tools

Набор полезных инструментов для разработчика.

## Установка

```
### Для всех (HTTPS)

```bash
git clone https://github.com/kapuzev/leerov-tools.git ~/leerov-tools && bash ~/leerov-tools/bin/setup.sh
```

### Для меня (SSH)
```bash
git clone git@github.com:kapuzev/leerov-tools.git ~/leerov-tools && bash ~/leerov-tools/bin/setup.sh
```

## Структура

- `bin/` - исполняемые скрипты
- `config/` - конфигурационные файлы
- `lib/` - библиотечные функции
- `scripts/` - вспомогательные скрипты
- `guides/` - гайды
- `misc/` - разное

## Основные команды

После установки все скрипты из `bin/` будут доступны в PATH:

- `clean.sh` - очистка кэша и временных файлов
- `crun.sh` - компиляция и запуск C программ
- `peer-review.sh` - проверка кода для ревью
- `push-repo.sh` - git push с проверкой SSH
- `show.sh` - просмотр содержимого файлов
- и другие...

## Удаление

```bash
~/leerov-tools/bin/uninstall.sh
```
