
struct TestModel <: AbstractModelDefinition end
QEDbase.fundamental_interaction_type(::TestModel) = :test_interaction

struct WrongTestModel <: AbstractModelDefinition end
QEDbase.fundamental_interaction_type(::WrongTestModel) = :test_interaction
