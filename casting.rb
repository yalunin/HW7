class Person
  attr_reader :name, :gender
  # @param [Person] parameters
  def initialize(parameters)
    @name = parameters[:name]
    @gender = parameters[:gender]
  end

end

class Actor < Person
  @@all_actors = []
  attr_reader :age

  def initialize(parameters)
    @age = parameters[:age]
    super
    @@all_actors << self
  end

  def self.all_actors
    @@all_actors
  end

  def return_films
    b = []
    Role.all_roles.each do |rol|

      b << rol if rol.age_for_role.include?(@age) && rol.sex == gender || rol.sex == "all"

    end
    b
  end


end

class Commission < Person
  @@all_commisions = []

  def initialize(parameters)
    @@all_commisions << self
    super
  end

  def self.all_commisions
    @@all_commisions
  end

  def evaluation(count_of_words, actor)
    if count_of_words < 30 && self.gender == "woman"
      return rand(1..7)
    end
    if self.gender == "man" && actor.gender == "woman" && (18..25).include?(actor.age)
      return rand(7..10)
    end
    rand(1..10)
  end
end


class Role
  @@all_roles = []
  attr_reader :age_for_role, :sex, :theme

  def initialize(parameters)
    @theme = parameters[:theme]
    @age_for_role = parameters[:age_for_role]
    @sex = parameters[:sex]
    @@all_roles << self
  end

  def pretend
    a = []

    Actor.all_actors.each do |act|

      if @age_for_role.include?(act.age) && act.gender == @sex || @sex == "all"
        a.push(act.name)
      end

    end

    "Претенденты на роль #{@theme}: #{a}"
  end

  def self.all_roles
    @@all_roles
  end
end

class Action
  attr_reader :duration, :themes

  def initialize(actor, *presents)
    @actor = actor
    @themes = []
    @text = []
    @duration = []

    presents.each do |pres|
      if @themes.include?(pres[:theme])
        raise "Может быть только одно выступление на одну тему"
      else
        @themes << pres[:theme]
      end
      @text << pres[:text]
      File.open(pres[:text]).each do |line|
        @duration << line.split(" ").size
      end
    end

  end


  def play(films)
    set = Array.new(films.length, false)
    array = [films, set]
    @films_hash = Hash[*array.transpose.flatten]

    films.each do |film|
      self.themes.each do |them|
        if film.theme == them && !@films_hash[film]
          @films_hash[film] = true
        end
      end
    end
    @films_hash
  end

  def rate
    @result_table = Hash.new
    @films_hash.each do |film, conf|
      #оцениваем только те выступления, на которые есть разрешение
      if conf
        puts "\nОцениваем выступление актёра #{@actor.name} на роль #{film.theme}"
        avn = []
        n = 0
        Commission.all_commisions.each do |commissioner|
          avn << commissioner.evaluation(@duration[@themes.index(film.theme)], @actor)
          puts "Член жюри #{commissioner.name} ставит оценку #{avn[n]}"
          n += 1
        end
        avg = avn.inject(0) { |result, elem| result + elem }/1.0/avn.size
        @result_table[film.theme.to_sym] = avg
        puts "Средняя оценка #{avg}"
      end
    end
  end

  def best_chooise
    puts "Наиболее лучший вариант для актёра #{@actor.name} #{@result_table.max}"
  end

  def all_time
    puts "Общая продолжительность выступлений актёра #{@actor.name} - #{@duration.inject(0) { |result, elem| result + elem }} слов"
  end
end

#Создаём актёров
evs = Actor.new({name: "evs", age: 21, gender: "man"})
egor = Actor.new({name: "egor", age: 22, gender: "man"})
masha = Actor.new({name: "masha", age: 18, gender: "woman"}) # !> assigned but unused variable - masha
dasha = Actor.new({name: "dasha", age: 15, gender: "woman"}) # !> assigned but unused variable - dasha

#Создаём жюри
lera = Commission.new({name: "lera", gender: "woman"}) # !> assigned but unused variable - lera
polina = Commission.new({name: "polina", gender: "woman"}) # !> assigned but unused variable - polina
sasha = Commission.new({name: "sashs", gender: "man"}) # !> assigned but unused variable - sasha
misha = Commission.new({name: "misha", gender: "man"}) # !> assigned but unused variable - misha

#Создаём роли
film1 = Role.new({theme: "love", age_for_role: 17..25, sex: "woman"})
film2 = Role.new({theme: "comedy", age_for_role: 12..25, sex: "man"})
film3 = Role.new({theme: "action", age_for_role: 15..25, sex: "man"})
film4 = Role.new({theme: "adult", age_for_role: 18..25, sex: "all"})

# {--метод .pretend - в классе Role. показывает подходящих актёров для фильма--} #
#определем наиболее подходищих актёров на роли
film1.pretend # => "Претенденты на роль love: [\"masha\"]"
film2.pretend # => "Претенденты на роль comedy: [\"evs\", \"egor\"]"
film3.pretend # => "Претенденты на роль action: [\"evs\", \"egor\"]"
film4.pretend # => "Претенденты на роль adult: [\"evs\", \"egor\", \"masha\", \"dasha\"]"

#Создаём выступления
evs_presents = Action.new(evs, {theme: "comedy", text: "text.txt"}, {theme: "love", text: "text.txt"}, {theme: "action", text: "text.txt"})
egor_presents = Action.new(egor, {theme: "action", text: "text.txt"})

#Даём актёрам выступить. Метод .return_films - возвращает подходящие фильмы для указанного актёра.
#Формируем хэш с фильмами, где в качестве ключа - фильмы, а значение - true либо false, в зависимости от наличия выступления и совпадения темы.
evs_presents.play(evs.return_films)
egor_presents.play(egor.return_films)

#Оцениваем выступление
evs_presents.rate

#Наилучший вариант для актёра
evs_presents.best_chooise

#Общая продолжительность выступлений актёра. Общее кол-во слов.
evs_presents.all_time
egor_presents.all_time

# >> Оцениваем выступление актёра evs на роль comedy
# >> Член жюри lera ставит оценку 6
# >> Член жюри polina ставит оценку 6
# >> Член жюри sashs ставит оценку 9
# >> Член жюри misha ставит оценку 9
# >> Средняя оценка 7.5
# >> 
# >> Оцениваем выступление актёра evs на роль action
# >> Член жюри lera ставит оценку 3
# >> Член жюри polina ставит оценку 3
# >> Член жюри sashs ставит оценку 5
# >> Член жюри misha ставит оценку 1
# >> Средняя оценка 3.0
# >> Наиболее лучший вариант для актёра evs [:comedy, 7.5]
# >> Общая продолжительность выступлений актёра evs - 42 слов
# >> Общая продолжительность выступлений актёра egor - 14 слов