class Person
  attr_accessor :first_name, :last_name, :email

  def initialize (first, last, email_domain)
    @first_name = first
    @last_name = last
    @email = "#{first}.#{last}@#{email_domain}"
  end
end

class PersonGenerator
  # http://www.ssa.gov/oact/babynames/
  DEFAULT_FIRST_NAMES = %w{Isabella Jacob Sophia Ethan Emma Michael Olivia Jayden Ava William Emily Alexander Abigail Noah Madison Daniel Chloe Aiden Mia Anthony}

  #http://names.mongabay.com/most_common_surnames.htm
  DEFAULT_LAST_NAMES = ["SMITH", "JOHNSON", "WILLIAMS", "JONES", "BROWN", "DAVIS", "MILLER", "WILSON", "MOORE", "TAYLOR", "ANDERSON", "THOMAS", "JACKSON", "WHITE", "HARRIS", "MARTIN", "THOMPSON", "GARCIA", "MARTINEZ", "ROBINSON", "CLARK", "RODRIGUEZ", "LEWIS", "LEE", "WALKER", "HALL", "ALLEN", "YOUNG", "HERNANDEZ", "KING", "WRIGHT", "LOPEZ", "HILL", "SCOTT", "GREEN", "ADAMS", "BAKER", "GONZALEZ", "NELSON", "CARTER", "MITCHELL", "PEREZ", "ROBERTS", "TURNER", "PHILLIPS", "CAMPBELL", "PARKER", "EVANS", "EDWARDS", "COLLINS", "STEWART", "SANCHEZ", "MORRIS", "ROGERS", "REED", "COOK", "MORGAN", "BELL", "MURPHY"]

  DEFAULT_DOMAINS = ['acmecorp.com']

  def initialize(domains=DEFAULT_DOMAINS, firsts=DEFAULT_FIRST_NAMES, lasts=DEFAULT_LAST_NAMES)
    @i = rand * 100
    @firsts = firsts
    @lasts = lasts
    @email_domains = domains || DEFAULT_DOMAINS
  end

  def next_person
    first_name = @firsts[@i % @firsts.length].capitalize
    last_name = @lasts[@i % @lasts.length].capitalize
    email = @email_domains[@i % @email_domains.length]
    Person.new(first_name, last_name, email)
  end

end

