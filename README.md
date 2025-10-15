# nuPlan_docker
## Quick start
### 1. Install nuPlan datasets 

[データセットアップ](https://nuplan-devkit.readthedocs.io/en/latest/dataset_setup.html)に従って[ダウンロードページ](https://www.nuscenes.org/nuplan#download)から以下の２つのファイルをダウンロード  

- nuplan-maps-v1.0.zip
- nuplan-v1.1_mini.zip

以下のようなディレクトリ構造になるように，ダウンロードしたファイルを配置．
```
~/nuplan
├── exp
│   └── ${USER}
│       ├── cache
│       │   └── <cached_tokens>
│       └── exp
│           └── my_nuplan_experiment
└── dataset
    ├── maps
    │   ├── nuplan-maps-v1.0.json
    │   ├── sg-one-north
    │   │   └── 9.17.1964
    │   │       └── map.gpkg
    │   ├── us-ma-boston
    │   │   └── 9.12.1817
    │   │       └── map.gpkg
    │   ├── us-nv-las-vegas-strip
    │   │   └── 9.15.1915
    │   │       └── map.gpkg
    │   └── us-pa-pittsburgh-hazelwood
    │       └── 9.17.1937
    │           └── map.gpkg
    └── nuplan-v1.1
        ├── splits 
        │     ├── mini 
        │     │    ├── 2021.05.12.22.00.38_veh-35_01008_01518.db
        │     │    ├── 2021.06.09.17.23.18_veh-38_00773_01140.db
        │     │    ├── ...
        │     │    └── 2021.10.11.08.31.07_veh-50_01750_01948.db
        │     └── trainval
        │          ├── 2021.05.12.22.00.38_veh-35_01008_01518.db
        │          ├── 2021.06.09.17.23.18_veh-38_00773_01140.db
        │          ├── ...
        │          └── 2021.10.11.08.31.07_veh-50_01750_01948.db
        └── sensor_blobs   
              ├── 2021.05.12.22.00.38_veh-35_01008_01518                                           
              │    ├── CAM_F0
              │    │     ├── c082c104b7ac5a71.jpg
              │    │     ├── af380db4b4ca5d63.jpg
              │    │     ├── ...
              │    │     └── 2270fccfb44858b3.jpg
              │    ├── CAM_B0
              │    ├── CAM_L0
              │    ├── CAM_L1
              │    ├── CAM_L2
              │    ├── CAM_R0
              │    ├── CAM_R1
              │    ├── CAM_R2
              │    └──MergedPointCloud 
              │         ├── 03fafcf2c0865668.pcd  
              │         ├── 5aee37ce29665f1b.pcd  
              │         ├── ...                   
              │         └── 5fe65ef6a97f5caf.pcd  
              │
              ├── 2021.06.09.17.23.18_veh-38_00773_01140 
              ├── ...                                                                            
              └── 2021.10.11.08.31.07_veh-50_01750_01948
```

## 2. Docker setup
```
git clone -b 11.7.1-cudnn8-devel-ubuntu22.04-nuPlan https://github.com/masakifujiwara022/nuPlan_docker.git
cd nuPlan_docker
docker compose up -d
./login.sh
```

## 3. Running sample scripts
### Training
```
python3 nuplan-devkit/nuplan/planning/script/run_training.py \
    experiment_name=raster_experiment \
    py_func=train \
    +training=training_raster_model \
    scenario_builder=nuplan_mini \
    scenario_filter.limit_total_scenarios=500 \
    lightning.trainer.params.max_epochs=10 \
    data_loader.params.batch_size=8 \
    data_loader.params.num_workers=8
```
### Simulation (open-loop)
```
python3 nuplan-devkit/nuplan/planning/script/run_simulation.py \
    +simulation=open_loop_boxes \
    planner=simple_planner \
    scenario_builder=nuplan_mini \
    scenario_filter=all_scenarios \
    scenario_filter.scenario_types="[near_multiple_vehicles, on_pickup_dropoff, starting_unprotected_cross_turn, high_magnitude_jerk]" \
    scenario_filter.num_scenarios_per_type=10
```
### Simulation with ml_planner (closed-loop)
> [!NOTE]
> モデルのパスを置き換えて下さい 'planner.ml_planner.checkpoint_path="REPLACE.ckpt"'
```
python3 nuplan-devkitnuplan/planning/script/run_simulation.py \
    '+simulation=closed_loop_reactive_agents' \
    'model=raster_model' \
    'planner=ml_planner' \
    'planner.ml_planner.model_config=${model}' \
    'planner.ml_planner.checkpoint_path="REPLACE.ckpt"' \
    'scenario_builder=nuplan_mini' \
    'scenario_filter=all_scenarios' \
    'scenario_filter.scenario_types=[near_multiple_vehicles, on_pickup_dropoff, starting_unprotected_cross_turn, high_magnitude_jerk]' \
    'scenario_filter.num_scenarios_per_type=10'
```

### Dashboard (nuBoard)
```
python3 nuplan/planning/script/run_nuboard.py
```
<img width="2560" height="1440" alt="image" src="https://github.com/user-attachments/assets/0be0c3f3-cf25-4d98-8505-bfe767932cde" />
