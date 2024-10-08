[Mesh]
  [Cube]
  type = FileMeshGenerator
  file = DRAGen_RVE_16G.e
  []
  [create_sidesets]
    type = SideSetsFromNodeSetsGenerator
    input = Cube
  []
  ### Center node to stablize necessary?
  [center_node]
    type = BoundingBoxNodeSetGenerator
    input = create_sidesets
    new_boundary = 100
    top_right = '0.0021 0.0021 0.0021'
    bottom_left = '0.0020 0.0020 0.0020'
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
  [./global_strain]
    order = SIXTH
    family = SCALAR
  [../]
[]

[Physics]
    [SolidMechanics]
      # QuasiStatic action for generating the tensor mechanics kernels, variables,
      # strain calculation material, and the auxilliary system for visualization
      [QuasiStatic]
        [./stress_div]
          strain = FINITE
          add_variables = true
          global_strain = global_strain #global strain contribution
          generate_output = 'strain_xx strain_yy strain_zz
                            stress_xx stress_zz stress_yy vonmises_stress'
        [../]
      [../]
      # GlobalStrain action for generating the objects associated with the global
      # strain calculation and associated displacement visualization
      [./GlobalStrain]
        [./global_strain]
          scalar_global_strain = global_strain
          displacements = 'u_x u_y u_z'
          auxiliary_displacements = 'disp_x disp_y disp_z'
          global_displacements = 'ug_x ug_y ug_z'
        [../]
      [../]
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
   [./Periodic]
     [./all]
       variable = 'u_x u_y u_z'
       auto_direction = 'x y'
     [../]
   [../]

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
  [./anchor_y]
    type = DirichletBC
    variable = 'u_y'
    boundary = 100
    value = 0
    [../]
  [./anchor_x]
    type = DirichletBC
    variable = 'u_x'
    boundary = 100
    value = 0
  [../]
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