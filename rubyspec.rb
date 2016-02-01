class Tclass
  def simple (num)
    puts num
  end
end


# Method Specification
class MethodSpec
  def initialize (mname, cname, args)
    @mname  = mname
    @cname  = cname
    @args   = args
  end

  def mname
    @mname
  end

  def cname
    @cname
  end

  def args
    @args
  end

end

# Conflict Object
class ConflictData
  def initialize
    @mcs = []
  end

  def add_method (newmcs)
    @mcs << newmcs
  end

  def get_methods
    return @mcs
  end
end


# Internal DSL for specifying conflict.
class ConflictSpecification
  def conflict (method1, class1, argsetm1, method2, class2, argsetm2)
    # Get the class for method1
    klass1 = eval(class1)
    k1 = klass1.new

    # Bind the method1
    mthd1 = method1.bind(klass1.new)

    # Execute the method if needed.
    mthd1.call(argsetm1)

    # Get the class for method2
    klass2 = eval(class2)
    k2 = klass2.new

    # Bind the method2
    mthd2 = method2.bind(klass2.new)

    # Execute the method if needed.
    mthd2.call(argsetm2)

    # Assigning to method Specification
    mspec1 = MethodSpec.new(mthd1, klass1, argsetm1)
    mspec2 = MethodSpec.new(mthd2, klass2, argsetm2)

    cd = ConflictData.new
    cd.add_method(mspec1)
    cd.add_method(mspec2)

    # Accessing the method specification
    mcs = cd.get_methods
    mcs.each {|mc|
      mc.mname.call(10)
    }

  end
end



# This is how the user will specify --
# Assuming the application has a class "Tclass" and the method 
# in conflict is "simple".

cs = ConflictSpecification.new
cs.conflict(Tclass.instance_method(:simple), Tclass.to_s, 9,
            Tclass.instance_method(:simple), Tclass.to_s, 9)

