[Mesh]
  [Cube]
  type = FileMeshGenerator
  file = DRAGen_RVE_16G.e
  []
  [create_sideset]
    type = SideSetsFromNodeSetsGenerator
    input = Cube
  []
[]


[GlobalParams]
  displacements = 'u_x u_y u_z'
[]

[Variables]
  [./u_x]
    order = FIRST
    family = LAGRANGE
  [../]
  [./u_y]
    order = FIRST
    family = LAGRANGE
  [../]
  [./u_z]
    order = FIRST
    family = LAGRANGE
  [../]
[]


[Modules/TensorMechanics/Master]
  [./block1]
    strain = FINITE
    add_variables = true
    generate_output = 'stress_zz stress_xx stress_xy stress_xz stress_yy stress_yz strain_xx strain_xy strain_xz strain_yy strain_yz strain_zz vonmises_stress'
  [../]
[]


[UserObjects]
    [./Euler]
      type = PropertyReadFile
      prop_file_name = 'EulerAngles.txt'
      read_type = 'block'
      # Enter file data as prop#1, prop#2, .., prop#nprop
      nprop = 3
      nblock = 44
    [../]
  []
  
  [Materials]
    [./elasticity_tensor]
      type = ComputeElasticityTensorCP
      C_ijkl = '231.4e3 134.7e3 134.7e3 231.4e3 134.7e3 231.4e3 116.4e3 116.4e3 116.4e3'
      fill_method = symmetric9
      read_prop_user_object = Euler
    [../]
  [./stress]
    type = ComputeMultipleCrystalPlasticityStress
    crystal_plasticity_models = 'trial_xtalpl'
    tan_mod_type = exact
  [../]
  [./trial_xtalpl]
    type = CrystalPlasticityKalidindiUpdate
    number_slip_systems = 12
    slip_sys_file_name = input_slip_sys.txt
  [../]
[]

[BCs]
# VVVV ########### Uncomment for PBC ###### VVVV
#   [./Periodic]
#     [./all]
#       variable = 'u_x u_y u_z'
#       auto_direction = 'x y'
#     [../]
#   [../]
# ^^^^ ########### Uncomment for PBC ###### ^^^
  [./top]
    type = FunctionDirichletBC
    variable = 'u_z'
    boundary = 'front'
    function = 0.002*t
  [../]
  [./back]
    type = DirichletBC
    variable = 'u_z'
    boundary = 'back'
    value = 0
  [../]
# V###### Comment out for PBC ########V
  [./bottom]
    type = DirichletBC
    variable = 'u_y'
    boundary = 'bottom'
    value = 0
    [../]
  [./left]
    type = DirichletBC
    variable = 'u_x'
    boundary = 'left'
    value = 0
  [../]
# ^######^ Comment out for PBC ^########^
[]


[Executioner]

  type = Transient
  solve_type = 'PJFNK'
  petsc_options = '-snes_ksp_ew'
  petsc_options_iname = '-pc_type -pc_hypre_type -ksp_gmres_restart'
  petsc_options_value = 'hypre    boomeramg          31'
  line_search = 'none'
  l_max_its = 45
  nl_max_its = 50
  nl_rel_tol = 1e-8
  nl_abs_tol = 1e-6
  l_tol = 1e-8
  start_time = 0.0
  end_time = 0.125
  dt = 0.00025
[]

[Outputs]
  execute_on = 'timestep_end'
  print_linear_residuals = false
  exodus = true
[]

[Postprocessors]
[./Strain_zz]
    type = ElementAverageValue
    variable = strain_zz
[../]
[./Stress_zz]
    type = ElementAverageValue
    variable = stress_zz
[../]
[]