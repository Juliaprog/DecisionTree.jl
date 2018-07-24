
@testset "int32_precision.jl" begin

Random.srand(16)

n,m = 10^3, 5;
features = Array{Any}(undef, n, m);
features[:,:] = randn(n, m);
features[:,1] = round.(Int32, features[:,1]); # convert a column of 32bit integers
weights = rand(-1:1,m);
labels = round.(Int32, features * weights);

model = build_stump(labels, features)
preds = apply_tree(model, features)
@test typeof(preds) == Vector{Int32}
@test depth(model) == 1

n_subfeatures       = Int32(0)
max_depth           = Int32(-1)
min_samples_leaf    = Int32(1)
min_samples_split   = Int32(2)
min_purity_increase = 0.0
model = build_tree(
        labels, features,
        n_subfeatures, max_depth,
        min_samples_leaf,
        min_samples_split,
        min_purity_increase)
preds = apply_tree(model, features)
cm = confusion_matrix(labels, preds)
@test typeof(preds) == Vector{Int32}
@test cm.accuracy > 0.95

n_subfeatures       = Int32(0)
n_trees             = Int32(10)
partial_sampling    = 0.7
max_depth           = Int32(-1)
model = build_forest(
        labels, features,
        n_subfeatures,
        n_trees,
        partial_sampling,
        max_depth)
preds = apply_forest(model, features)
cm = confusion_matrix(labels, preds)
@test typeof(preds) == Vector{Int32}
@test cm.accuracy > 0.95

n_iterations        = Int32(15)
model, coeffs = build_adaboost_stumps(labels, features, n_iterations);
preds = apply_adaboost_stumps(model, coeffs, features);
cm = confusion_matrix(labels, preds)
@test typeof(preds) == Vector{Int32}
@test cm.accuracy > 0.3

println("\n##### nfoldCV Classification Tree #####")
pruning_purity      = 0.9
n_folds             = Int32(3)
accuracy = nfoldCV_tree(labels, features, pruning_purity, n_folds)
@test mean(accuracy) > 0.7

println("\n##### nfoldCV Classification Forest #####")
n_subfeatures       = Int32(2)
n_trees             = Int32(10)
accuracy = nfoldCV_forest(labels, features, n_subfeatures, n_trees, n_folds)
@test mean(accuracy) > 0.7

println("\n##### nfoldCV Adaboosted Stumps #####")
n_iterations        = Int32(15)
accuracy = nfoldCV_stumps(labels, features, n_iterations, n_folds)
@test mean(accuracy) > 0.3

end # @testset